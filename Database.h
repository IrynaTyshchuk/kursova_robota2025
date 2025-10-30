#ifndef DATABASE_H
#define DATABASE_H
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QDebug>
#include <QString>
#include <QByteArray>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);
    Q_INVOKABLE bool registerUser(const QString &name, const QString &email, const QString &password);
    Q_INVOKABLE bool loginUser(const QString &email, const QString &password);

private:
    QSqlDatabase db;
    void initializeDatabase();
    QByteArray hashPassword(const QString &password);
};

#endif
