#include "Database.h"
#include <QSqlError>
#include <QVariant>
#include <QtGlobal>

Database::Database(QObject *parent)
    : QObject(parent)
{
    initializeDatabase();
}

void Database::initializeDatabase()
{
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("diary.db");

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
}

QByteArray Database::hashPassword(const QString &password)
{
    // УВАГА: Це дуже простий хеш для прикладу. Для реальних додатків використовуйте QCryptographicHash.
    quint32 hash = 0xAAAAAAAA;
    for (const QChar &c : password) {
        hash = hash ^ (c.unicode() << 5);
        hash = hash + (hash >> 3);
    }
    QString hashString = QString("%1").arg(hash, 8, 16, QChar('0'));

    qDebug() << "Простий хеш для пароля:" << hashString;
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

bool Database::loginUser(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty()) {
        qWarning() << "Попередження: Усі поля мають бути заповнені для входу.";
        return false;
    }

    QByteArray providedHash = hashPassword(password);

    QSqlQuery query;
    query.prepare("SELECT password_hash FROM users WHERE email = :email");
    query.bindValue(":email", email);

    if (query.exec() && query.next()) {
        QByteArray storedHash = query.value(0).toByteArray();

        if (storedHash == providedHash) {
            qDebug() << "Вхід успішний для користувача:" << email;
            return true;
        }
    }

    qWarning() << "Помилка: Невірний email або пароль для:" << email;
    return false;
}
