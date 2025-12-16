#include "NotificationManager.h"
#include <QDebug>
#include <QCoreApplication>
#include <QVariantMap>
#include <QVariantList>
#include <QDateTime>
#include <QTimer>
#include <QSqlQuery>
#include <QtMath>
#include "Database.h"

NotificationManager::NotificationManager(Database *db, QObject *parent)
    : QObject(parent)
    , m_db(db)
    , m_currentUserId(-1)
{
    m_checkTimer = new QTimer(this);
    m_checkTimer->setInterval(30000); // Перевірка кожні 30 секунд для десктопу
    connect(m_checkTimer, &QTimer::timeout, this, &NotificationManager::checkNotifications);
}

NotificationManager::~NotificationManager()
{
    stop();
}

void NotificationManager::start()
{
    if (!m_checkTimer->isActive()) {
        m_checkTimer->start();
        qDebug() << "Менеджер сповіщень запущено (Desktop)";
    }
}

void NotificationManager::stop()
{
    m_checkTimer->stop();
    qDebug() << "Менеджер сповіщень зупинено";
}

void NotificationManager::onUserLoggedIn(int userId)
{
    m_currentUserId = userId;
    loadAndScheduleNotifications();
    start();
}

void NotificationManager::onUserLoggedOut()
{
    m_currentUserId = -1;
    stop();
}

void NotificationManager::loadAndScheduleNotifications()
{
    if (m_currentUserId <= 0 || m_db == nullptr) return;

    QVariantList notes = m_db->getNotesForUser(m_currentUserId);
    QDateTime now = QDateTime::currentDateTime();

    for (const QVariant &noteVar : notes) {
        QVariantMap note = noteVar.toMap();

        int noteId = note["id"].toInt();
        QString executionDateStr = note["execution_date"].toString();
        QString createdTimeStr = note["created_time"].toString();

        if (executionDateStr.isEmpty() || createdTimeStr.isEmpty()) {
            continue;
        }

        QDateTime plannedDateTime = QDateTime::fromString(executionDateStr + " " + createdTimeStr, "yyyy-MM-dd HH:mm");
        if (!plannedDateTime.isValid()) {
            continue;
        }

        // Якщо має спрацювати у проміжок часу від зараз до першої перевірки таймера (30 сек)
        if (plannedDateTime > now && plannedDateTime <= now.addSecs(m_checkTimer->interval() / 1000)) {

            QString title = "Нагадування: " + note["title"].toString();
            QString message = note["content"].toString();
            qint64 msToWait = now.msecsTo(plannedDateTime);

            // Затримка до запланованого часу
            QTimer::singleShot(msToWait, this, [this, title, message, noteId]() {
                emit notificationTriggered(title, message, noteId);
            });

            qDebug() << "Заплановано (на старті) сповіщення для нотатки" << noteId
                     << "на" << plannedDateTime.toString("dd.MM HH:mm");
        }
    }
}

void NotificationManager::checkNotifications()
{
    if (m_currentUserId <= 0 || m_db == nullptr) return;

    QDateTime now = QDateTime::currentDateTime();
    QVariantList notes = m_db->getNotesForUser(m_currentUserId);

    for (const QVariant &noteVar : notes) {
        QVariantMap note = noteVar.toMap();

        QString executionDateStr = note["execution_date"].toString();
        QString createdTimeStr = note["created_time"].toString();
        int repeatMinutes = note["repeatMinutes"].toInt();
        int noteId = note["id"].toInt();

        if (executionDateStr.isEmpty() || createdTimeStr.isEmpty()) continue;

        QString plannedDateTimeStr = executionDateStr + " " + createdTimeStr;
        QDateTime plannedDateTime = QDateTime::fromString(plannedDateTimeStr, "yyyy-MM-dd HH:mm");

        if (!plannedDateTime.isValid()) continue;

        // Перевірка: Чи настав запланований час?
        if (plannedDateTime <= now) {

            // 1. Викликаємо сповіщення
            emit notificationTriggered(
                "Нагадування: " + note["title"].toString(),
                note["content"].toString(),
                noteId
                );

            qDebug() << "Сповіщення спрацювало для ID" << noteId << "на час" << plannedDateTime.toString("dd.MM HH:mm");

            // 2. Логіка повтору:
            if (repeatMinutes > 0) {
                QDateTime nextPlannedDateTime = plannedDateTime;

                // Розраховуємо наступний час, доки він не стане в майбутньому
                while (nextPlannedDateTime <= now) {
                    nextPlannedDateTime = nextPlannedDateTime.addSecs(repeatMinutes * 60);
                }

                // Оновлюємо базу даних на наступний цикл
                m_db->updateNoteExecutionTime(noteId, nextPlannedDateTime);

                qDebug() << "Повторюване завдання ID" << noteId << "оновлено на" << nextPlannedDateTime.toString("dd.MM HH:mm");

            } else {
                // 3. Якщо це одиничне завдання, очищуємо дату виконання (NULL)
                m_db->updateNoteExecutionTime(noteId, QDateTime());
                qDebug() << "Одиничне завдання ID" << noteId << "виконано. Дата очищена.";
            }
        }
    }
}
