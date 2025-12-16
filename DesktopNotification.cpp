#include "DesktopNotification.h"
#include <QApplication>
#include <QMenu>
#include <QAction>
#include <QDebug>
#include <QProcess>
#include <QIcon>
#include <QPixmap>
#include <QPainter>
#include <QFont>
#include <QStyle>

#ifdef Q_OS_WINDOWS
#include <windows.h>
#include <winuser.h>
#endif

// --- Допоміжна функція для створення мінімальної іконки (Windows Standard) ---
// Ця функція гарантує дійсний QIcon (розмір 32x32) для QSystemTrayIcon.
QIcon generateDefaultIcon() {
    QPixmap pixmap(32, 32);
    pixmap.fill(Qt::transparent);

    QPainter painter(&pixmap);
    painter.setRenderHint(QPainter::Antialiasing);

    // Малюємо синій круг як заглушку
    QColor blueColor("#3F51B5");
    painter.setBrush(blueColor);
    painter.drawEllipse(2, 2, 28, 28);

    // Додаємо білий символ "D" (Diary)
    painter.setPen(Qt::white);
    QFont font("Arial", 16);
    font.setBold(true);
    painter.setFont(font);
    painter.drawText(pixmap.rect(), Qt::AlignCenter, "D");

    return QIcon(pixmap);
}
// --------------------------------------------------------

DesktopNotification::DesktopNotification(QObject *parent)
    : QObject(parent)
    , m_trayIcon(nullptr)
    , m_notificationTimer(nullptr)
    , m_trayIconVisible(false)
{
    setupTrayIcon();

    m_notificationTimer = new QTimer(this);
    m_notificationTimer->setInterval(1000);
    connect(m_notificationTimer, &QTimer::timeout, this, &DesktopNotification::showNextNotification);
    m_notificationTimer->start();
}

DesktopNotification::~DesktopNotification()
{
    if (m_trayIcon) {
        delete m_trayIcon;
    }
}

void DesktopNotification::setupTrayIcon()
{
    if (!QSystemTrayIcon::isSystemTrayAvailable()) {
        qDebug() << "System tray не доступний";
        return;
    }

    m_trayIcon = new QSystemTrayIcon(this);

    // Створюємо контекстне меню для трея
    QMenu *trayMenu = new QMenu();
    QAction *showAction = new QAction("Показати щоденник", trayMenu);
    connect(showAction, &QAction::triggered, this, [this]() {
        emit notificationClicked(0);
    });

    QAction *quitAction = new QAction("Вийти", trayMenu);
    connect(quitAction, &QAction::triggered, qApp, &QCoreApplication::quit);
    trayMenu->addAction(showAction);
    trayMenu->addSeparator();
    trayMenu->addAction(quitAction);

    m_trayIcon->setContextMenu(trayMenu);

    // --- ЛОГІКА ГАРАНТОВАНОГО ВСТАНОВЛЕННЯ ІКОНКИ ---
    QIcon icon = QApplication::windowIcon();

    // 1. Спроба завантажити з QRC (через windowIcon)
    if (icon.isNull()) {
        // 2. Спроба завантажити напряму з ресурсу
        icon = QIcon(":/icons/images.png");
    }

    // 3. Якщо все ще недійсна, використовуємо згенеровану заглушку 32x32
    if (icon.isNull()) {
        icon = generateDefaultIcon();
        qWarning() << "Використано згенеровану іконку-заглушку (32x32).";
    }

    m_trayIcon->setIcon(icon);
    // --- КІНЕЦЬ ГАРАНТІЇ ---

    m_trayIcon->setToolTip("Щоденник");

    connect(m_trayIcon, &QSystemTrayIcon::activated, this, &DesktopNotification::onTrayIconActivated);

    m_trayIcon->show();
    m_trayIconVisible = true;
    qDebug() << "Іконка в системному треї показана";
}

void DesktopNotification::onTrayIconActivated(QSystemTrayIcon::ActivationReason reason)
{
    switch (reason) {
    case QSystemTrayIcon::Trigger:
    case QSystemTrayIcon::DoubleClick:
        emit notificationClicked(0);
        break;
    case QSystemTrayIcon::MiddleClick:
        break;
    default:
        break;
    }
}

void DesktopNotification::showNotification(const QString &title, const QString &message, int notificationId)
{
    qDebug() << "Сповіщення:" << title << "-" << message << "(ID:" << notificationId << ")";

    m_notificationQueue.append(qMakePair(title, message));

    if (m_trayIcon && m_trayIconVisible) {
        showTrayMessage(title, message);
    }

    // Логіка для платформ (залишено для повної підтримки)
#ifdef Q_OS_LINUX
    QProcess::execute("notify-send", QStringList() << title << message);
#endif

#ifdef Q_OS_MAC
    QString script = QString("display notification \"%1\" with title \"%2\"").arg(message, title);
    QProcess::execute("osascript", QStringList() << "-e" << script);
#endif
}

void DesktopNotification::showTrayMessage(const QString &title, const QString &message)
{
    if (!m_trayIcon || !m_trayIconVisible) return;

    m_trayIcon->showMessage(
        title,
        message,
        QSystemTrayIcon::Information,
        5000
        );
}

void DesktopNotification::showNextNotification()
{
    if (m_notificationQueue.isEmpty()) return;

    auto notification = m_notificationQueue.takeFirst();
    showTrayMessage(notification.first, notification.second);
}

void DesktopNotification::cancelNotification(int notificationId)
{
    qDebug() << "Скасувати сповіщення з ID:" << notificationId;
    m_notificationQueue.clear();
}
