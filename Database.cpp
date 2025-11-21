#include "Database.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>
#include <QVariantMap>
#include <QtGlobal>
#include <QDebug>
#include <QDateTime>
#include <QCryptographicHash>
#include <QStandardPaths>

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

    QSqlQuery query(db);
    bool success;

    success = query.exec("CREATE TABLE IF NOT EXISTS users ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                         "name TEXT NOT NULL,"
                         "email TEXT UNIQUE NOT NULL,"
                         "password_hash TEXT NOT NULL)");
    if (!success) { qCritical() << "Помилка: Не вдалося створити таблицю users:" << query.lastError().text(); }

    success = query.exec("CREATE TABLE IF NOT EXISTS task_types ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                         "name TEXT UNIQUE NOT NULL)");
    if (!success) { qCritical() << "Помилка: Не вдалося створити таблицю task_types:" << query.lastError().text(); }
    else {
        query.exec("INSERT OR IGNORE INTO task_types (name) VALUES ('Одиничне')");
        query.exec("INSERT OR IGNORE INTO task_types (name) VALUES ('Повторюване')");
    }

    success = query.exec("CREATE TABLE IF NOT EXISTS priorities ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                         "name TEXT UNIQUE NOT NULL,"
                         "color_hex TEXT)");
    if (!success) { qCritical() << "Помилка: Не вдалося створити таблицю priorities:" << query.lastError().text(); }
    else {
        query.exec("INSERT OR IGNORE INTO priorities (name, color_hex) VALUES ('Висока', '#F44336')");
        query.exec("INSERT OR IGNORE INTO priorities (name, color_hex) VALUES ('Середня', '#2196F3')");
        query.exec("INSERT OR IGNORE INTO priorities (name, color_hex) VALUES ('Низька', '#4CAF50')");
    }

    success = query.exec("CREATE TABLE IF NOT EXISTS activities ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                         "name TEXT UNIQUE NOT NULL)");
    if (!success) { qCritical() << "Помилка: Не вдалося створити таблицю activities:" << query.lastError().text(); }

    success = query.exec("CREATE TABLE IF NOT EXISTS repeat_options ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                         "name TEXT UNIQUE NOT NULL,"
                         "value_minutes INTEGER NOT NULL)");
    if (!success) { qCritical() << "Помилка: Не вдалося створити таблицю repeat_options:" << query.lastError().text(); }
    else {
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('Не повторювати', 0)");
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('10 хв', 10)");
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('30 хв', 30)");
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('1 год', 60)");
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('3 год', 180)");
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('6 год', 360)");
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('12 год', 720)");
        query.exec("INSERT OR IGNORE INTO repeat_options (name, value_minutes) VALUES ('1 день', 1440)");
    }

    success = query.exec("CREATE TABLE IF NOT EXISTS notes ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                         "user_id INTEGER NOT NULL,"
                         "title TEXT NOT NULL,"
                         "content TEXT NOT NULL,"
                         "task_type_id INTEGER NULL,"
                         "priority_id INTEGER NULL,"
                         "activity_id INTEGER NULL,"
                         "execution_date TEXT NULL,"
                         "repeat_option_id INTEGER NULL,"
                         "created_date TEXT NOT NULL,"
                         "created_time TEXT NOT NULL,"
                         "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,"
                         "FOREIGN KEY(task_type_id) REFERENCES task_types(id),"
                         "FOREIGN KEY(priority_id) REFERENCES priorities(id),"
                         "FOREIGN KEY(activity_id) REFERENCES activities(id),"
                         "FOREIGN KEY(repeat_option_id) REFERENCES repeat_options(id))");
    if (!success) { qCritical() << "Помилка: Не вдалося створити таблицю notes:" << query.lastError().text(); }

    if (!query.exec("ALTER TABLE notes ADD COLUMN execution_date TEXT NULL")) {
        qDebug() << query.lastError().text();
    }
    if (!query.exec("ALTER TABLE notes ADD COLUMN repeat_option_id INTEGER NULL")) {
        qDebug() << query.lastError().text();
    }
}

QByteArray Database::hashPassword(const QString &password)
{
    return QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
}

QString Database::hashPasswordToHex(const QString &password)
{
    QByteArray hash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
    return QString(hash.toHex());
}

int Database::getIdOnly(const QString &tableName, const QString &columnName, const QString &value)
{
    if (value.isEmpty()) return 0;

    QSqlQuery query(db);
    query.prepare(QString("SELECT id FROM %1 WHERE %2 = :value").arg(tableName, columnName));
    query.bindValue(":value", value);

    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }
    return 0;
}

int Database::getIdOrCreate(const QString &tableName, const QString &columnName, const QString &value)
{
    if (value.isEmpty()) {
        return 0;
    }

    QSqlQuery query(db);
    query.prepare(QString("SELECT id FROM %1 WHERE %2 = :value").arg(tableName, columnName));
    query.bindValue(":value", value);

    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }

    query.prepare(QString("INSERT INTO %1 (%2) VALUES (:value)").arg(tableName, columnName));
    query.bindValue(":value", value);

    if (query.exec()) {
        return query.lastInsertId().toInt();
    } else {
        qCritical() << "Помилка вставки в таблицю" << tableName << ":" << query.lastError().text();
        return -1;
    }
}

int Database::getUserIdByEmail(const QString &email)
{
    QSqlQuery query(db);
    query.prepare("SELECT id FROM users WHERE email = :email");
    query.bindValue(":email", email);
    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }
    return 0;
}

bool Database::registerUser(const QString &name, const QString &email, const QString &password)
{
    if (name.isEmpty() || email.isEmpty() || password.isEmpty()) {
        return false;
    }

    QSqlQuery query(db);
    query.prepare("INSERT INTO users (name, email, password_hash) VALUES (:name, :email, :password_hash)");
    query.bindValue(":name", name);
    query.bindValue(":email", email);
    query.bindValue(":password_hash", hashPasswordToHex(password));

    return query.exec();
}

QVariant Database::loginUser(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty()) {
        return QVariant();
    }

    QString providedHashHex = hashPasswordToHex(password);

    QSqlQuery query(db);
    query.prepare("SELECT id, name, password_hash FROM users WHERE email = :email");
    query.bindValue(":email", email);

    if (query.exec() && query.next()) {
        int userId = query.value("id").toInt();
        QString userName = query.value("name").toString();
        QString storedHashHex = query.value("password_hash").toString();

        if (storedHashHex == providedHashHex) {
            QVariantMap userData;
            userData["id"] = userId;
            userData["name"] = userName;
            userData["email"] = email;
            return userData;
        }
    }

    return QVariant();
}

QVariantList Database::getTaskTypes()
{
    QVariantList typesList;
    QSqlQuery query("SELECT id, name FROM task_types ORDER BY id ASC", db);
    while (query.next()) {
        QVariantMap type;
        type["id"] = query.value("id").toInt();
        type["name"] = query.value("name").toString();
        typesList.append(type);
    }
    return typesList;
}

QVariantList Database::getPriorities()
{
    QVariantList prioritiesList;
    QSqlQuery query("SELECT id, name, color_hex FROM priorities ORDER BY id ASC", db);
    while (query.next()) {
        QVariantMap priority;
        priority["id"] = query.value("id").toInt();
        priority["name"] = query.value("name").toString();
        priority["color"] = query.value("color_hex").toString();
        prioritiesList.append(priority);
    }
    return prioritiesList;
}

QVariantList Database::getActivities()
{
    QVariantList activitiesList;
    QSqlQuery query("SELECT id, name FROM activities ORDER BY id ASC", db);
    while (query.next()) {
        QVariantMap activity;
        activity["id"] = query.value("id").toInt();
        activity["name"] = query.value("name").toString();
        activitiesList.append(activity);
    }
    return activitiesList;
}

QVariantList Database::getRepeatOptions()
{
    QVariantList optionsList;
    QSqlQuery query("SELECT id, name FROM repeat_options ORDER BY value_minutes ASC", db);
    while (query.next()) {
        QVariantMap option;
        option["id"] = query.value("id").toInt();
        option["name"] = query.value("name").toString();
        optionsList.append(option);
    }
    return optionsList;
}

QVariant Database::addNote(int userId, const QVariantMap &noteData)
{
    if (userId <= 0 || noteData.value("title").toString().isEmpty()) {
        return QVariant();
    }

    int taskTypeId = getIdOnly("task_types", "name", noteData.value("taskType").toString());
    int priorityId = getIdOnly("priorities", "name", noteData.value("priority").toString());
    int activityId = getIdOrCreate("activities", "name", noteData.value("activityType").toString());
    int repeatOptionId = getIdOnly("repeat_options", "name", noteData.value("repeatOption").toString());

    if (activityId == -1) {
        return QVariant();
    }

    QString createdDate = QDateTime::currentDateTime().toString("yyyy-MM-dd");
    QString createdTime = QDateTime::currentDateTime().toString("HH:mm");
    QString executionDate = noteData.value("executionDate").toString();

    QSqlQuery query(db);
    query.prepare("INSERT INTO notes (user_id, title, content, task_type_id, priority_id, activity_id, execution_date, repeat_option_id, created_date, created_time) "
                  "VALUES (:user_id, :title, :content, :task_type_id, :priority_id, :activity_id, :execution_date, :repeat_option_id, :created_date, :created_time)");

    query.bindValue(":user_id", userId);
    query.bindValue(":title", noteData.value("title").toString());
    query.bindValue(":content", noteData.value("content").toString());
    query.bindValue(":task_type_id", taskTypeId > 0 ? QVariant(taskTypeId) : QVariant());
    query.bindValue(":priority_id", priorityId > 0 ? QVariant(priorityId) : QVariant());
    query.bindValue(":activity_id", activityId > 0 ? QVariant(activityId) : QVariant());
    query.bindValue(":execution_date", executionDate.isEmpty() ? QVariant() : executionDate);
    query.bindValue(":repeat_option_id", repeatOptionId > 0 ? QVariant(repeatOptionId) : QVariant());
    query.bindValue(":created_date", createdDate);
    query.bindValue(":created_time", createdTime);

    if (query.exec()) {
        return query.lastInsertId();
    } else {
        return QVariant();
    }
}

QVariantList Database::getNotesForUser(int userId)
{
    QVariantList notesList;

    if (userId <= 0) {
        return notesList;
    }

    QSqlQuery query(db);
    query.prepare("SELECT n.id, n.title, n.content, n.created_date, n.created_time, n.execution_date, "
                  "tt.name AS taskType, p.name AS priority, p.color_hex AS priorityColor, a.name AS activityType, "
                  "ro.name AS repeatOptionName "
                  "FROM notes n "
                  "LEFT JOIN task_types tt ON n.task_type_id = tt.id "
                  "LEFT JOIN priorities p ON n.priority_id = p.id "
                  "LEFT JOIN activities a ON n.activity_id = a.id "
                  "LEFT JOIN repeat_options ro ON n.repeat_option_id = ro.id "
                  "WHERE n.user_id = :user_id ORDER BY n.id DESC");
    query.bindValue(":user_id", userId);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap note;
            note["id"] = query.value("id").toInt();
            note["title"] = query.value("title").toString();
            note["content"] = query.value("content").toString();
            note["executionDate"] = query.value("execution_date").toString();
            note["repeatOption"] = query.value("repeatOptionName").toString();
            note["creation_time"] = query.value("created_time").toString();
            note["created_date"] = query.value("created_date").toString();
            note["taskType"] = query.value("taskType").toString();
            note["priority"] = query.value("priority").toString();
            note["priorityColor"] = query.value("priorityColor").toString();
            note["activityType"] = query.value("activityType").toString();
            notesList.append(note);
        }
    }

    return notesList;
}

bool Database::deleteNote(int noteId)
{
    if (noteId <= 0) {
        return false;
    }

    QSqlQuery query(db);
    query.prepare("DELETE FROM notes WHERE id = :id");
    query.bindValue(":id", noteId);

    if (query.exec()) {
        return query.numRowsAffected() > 0;
    }

    return false;
}
