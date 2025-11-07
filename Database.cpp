#include "Database.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>
#include <QVariantMap>
#include <QtGlobal>
#include <QDebug>
#include <QLocale>

Database::Database(QObject *parent)
    : QObject(parent)
{
    initializeDatabase();
}

void Database::initializeDatabase()
{
    if (QSqlDatabase::contains("qt_sql_default_connection")) {
        db = QSqlDatabase::database("qt_sql_default_connection");
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName("C:/Kurs/KURS/build/Desktop_Qt_6_10_0_MinGW_64_bit-Debug/diary.db");
    }
    if (!db.open()) {
        qCritical() << "Помилка: Не вдалося відкрити базу даних:" << db.lastError().text();
        return;
    }
    QSqlQuery query;
    if (!query.exec("CREATE TABLE IF NOT EXISTS users ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                    "name TEXT NOT NULL,"
                    "email TEXT UNIQUE NOT NULL,"
                    "password_hash BLOB NOT NULL)")) {
        qCritical() << "Помилка: Не вдалося створити таблицю users:" << query.lastError().text();
    } else {
        qDebug() << "База даних і таблиця users готові.";
    }
    if (!query.exec("CREATE TABLE IF NOT EXISTS notes ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                    "user_email TEXT NOT NULL,"
                    "title TEXT NOT NULL,"
                    "content TEXT NOT NULL,"
                    "date TEXT NOT NULL,"
                    "taskType TEXT,"
                    "priority TEXT,"
                    "activityType TEXT,"
                    "FOREIGN KEY(user_email) REFERENCES users(email) ON DELETE CASCADE)")) {
        qCritical() << "Помилка: Не вдалося створити таблицю notes:" << query.lastError().text();
    } else {
        qDebug() << "Таблиця notes готова.";
    }
}
QByteArray Database::hashPassword(const QString &password)
{
    quint32 hash = 0xAAAAAAAA;
    for (const QChar &c : password) {
        hash = hash ^ (c.unicode() << 5);
        hash = hash + (hash >> 3);
    }
    QString hashString = QString("%1").arg(hash, 8, 16, QChar('0'));
    return hashString.toUtf8();
}

bool Database::registerUser(const QString &name, const QString &email, const QString &password)
{
    if (name.isEmpty() || email.isEmpty() || password.isEmpty()) {
        qWarning() << "Попередження: Усі поля мають бути заповнені для реєстрації.";
        return false;
    }

    QSqlQuery query;
    query.prepare("INSERT INTO users (name, email, password_hash) VALUES (:name, :email, :password_hash)");
    query.bindValue(":name", name);
    query.bindValue(":email", email);
    query.bindValue(":password_hash", hashPassword(password));

    if (query.exec()) {
        qDebug() << "Користувач успішно зареєстрований:" << email;
        return true;
    } else {
        qCritical() << "Помилка реєстрації:" << query.lastError().text();
        return false;
    }
}

QVariant Database::loginUser(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty()) {
        qWarning() << "Попередження: Усі поля мають бути заповнені для входу.";
        return QVariant();
    }

    QByteArray providedHash = hashPassword(password);

    QSqlQuery query;
    query.prepare("SELECT name, password_hash FROM users WHERE email = :email");
    query.bindValue(":email", email);

    if (query.exec() && query.next()) {
        QString userName = query.value("name").toString();
        QByteArray storedHash = query.value("password_hash").toByteArray();

        if (storedHash == providedHash) {
            qDebug() << "Вхід успішний для користувача:" << email;
            QVariantMap userData;
            userData["name"] = userName;
            userData["email"] = email;
            return userData;
        }
    }

    qWarning() << "Помилка: Невірний email або пароль для:" << email;
    return QVariant();
}
QVariant Database::addNote(const QString &userEmail, const QVariantMap &noteData)
{
    if (userEmail.isEmpty() || noteData.isEmpty() || noteData.value("title").toString().isEmpty()) {
        qWarning() << "Попередження: Не вдалося додати нотатку. Недійсні дані.";
        return QVariant();
    }

    QSqlQuery query;
    query.prepare("INSERT INTO notes (user_email, title, content, date, taskType, priority, activityType) "
                  "VALUES (:user_email, :title, :content, :date, :taskType, :priority, :activityType)");

    query.bindValue(":user_email", userEmail);
    query.bindValue(":title", noteData.value("title").toString());
    query.bindValue(":content", noteData.value("content").toString());
    query.bindValue(":date", noteData.value("date").toString());
    query.bindValue(":taskType", noteData.value("taskType").toString());
    query.bindValue(":priority", noteData.value("priority").toString());
    query.bindValue(":activityType", noteData.value("activityType").toString());

    if (query.exec()) {
        QVariant lastId = query.lastInsertId();
        qDebug() << "Нотатку успішно додано. ID:" << lastId << "для:" << userEmail;
        return lastId;
    } else {
        qCritical() << "Помилка додавання нотатки:" << query.lastError().text();
        return QVariant();
    }
}

QVariantList Database::getNotesForUser(const QString &userEmail)
{
    QVariantList notesList;

    if (userEmail.isEmpty()) {
        qWarning() << "Попередження: Неможливо отримати нотатки. Відсутній email користувача.";
        return notesList;
    }

    QSqlQuery query;
    query.prepare("SELECT id, title, content, date, taskType, priority, activityType FROM notes WHERE user_email = :user_email ORDER BY id DESC");
    query.bindValue(":user_email", userEmail);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap note;
            note["id"] = query.value("id").toInt();
            note["title"] = query.value("title").toString();
            note["content"] = query.value("content").toString();
            note["date"] = query.value("date").toString();
            note["taskType"] = query.value("taskType").toString();
            note["priority"] = query.value("priority").toString();
            note["activityType"] = query.value("activityType").toString();
            notesList.append(note);
        }
        qDebug() << "Отримано" << notesList.count() << "нотаток для" << userEmail;
    } else {
        qCritical() << "Помилка отримання нотаток:" << query.lastError().text();
    }

    return notesList;
}
bool Database::deleteNote(int noteId)
{
    if (noteId <= 0) {
        qWarning() << "Попередження: Недійсний ID нотатки для видалення.";
        return false;
    }

    QSqlQuery query;
    query.prepare("DELETE FROM notes WHERE id = :id");
    query.bindValue(":id", noteId);

    if (query.exec()) {
        if (query.numRowsAffected() > 0) {
            qDebug() << "Нотатку з ID" << noteId << "успішно видалено.";
            return true;
        } else {
            qWarning() << "Попередження: Нотатку з ID" << noteId << "не знайдено для видалення.";
            return false;
        }
    } else {
        qCritical() << "Помилка видалення нотатки:" << query.lastError().text();
        return false;
    }
}
