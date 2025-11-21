#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariant>
#include <QVariantMap>
#include <QVariantList>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);

    Q_INVOKABLE bool registerUser(const QString &name, const QString &email, const QString &password);
    Q_INVOKABLE QVariant loginUser(const QString &email, const QString &password);

    Q_INVOKABLE QVariant addNote(int userId, const QVariantMap &noteData);
    Q_INVOKABLE QVariantList getNotesForUser(int userId);
    Q_INVOKABLE bool deleteNote(int noteId);

    Q_INVOKABLE QVariantList getTaskTypes();
    Q_INVOKABLE QVariantList getPriorities();
    Q_INVOKABLE QVariantList getActivities();
    Q_INVOKABLE QVariantList getRepeatOptions();

private:
    QSqlDatabase db;
    void initializeDatabase();

    QByteArray hashPassword(const QString &password);
    QString hashPasswordToHex(const QString &password);

    int getUserIdByEmail(const QString &email);

    int getIdOnly(const QString &tableName, const QString &columnName, const QString &value);

    int getIdOrCreate(const QString &tableName, const QString &columnName, const QString &value);
};

#endif // DATABASE_H
