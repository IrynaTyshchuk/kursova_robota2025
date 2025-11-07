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
    Q_INVOKABLE QVariant addNote(const QString &userEmail, const QVariantMap &noteData);
    Q_INVOKABLE QVariantList getNotesForUser(const QString &userEmail);
    Q_INVOKABLE bool deleteNote(int noteId);

private:
    QSqlDatabase db;
    void initializeDatabase();
    QByteArray hashPassword(const QString &password);
};

#endif
