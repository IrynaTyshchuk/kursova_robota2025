#ifndef NOTIFICATIONMANAGER_H
#define NOTIFICATIONMANAGER_H

#include <QObject>
#include <QTimer>
#include <QMap>
#include <QDateTime>
#include "Database.h"

class NotificationManager : public QObject
{
    Q_OBJECT

public:
    explicit NotificationManager(Database *db, QObject *parent = nullptr);
    ~NotificationManager();

    Q_INVOKABLE void onUserLoggedIn(int userId);
    Q_INVOKABLE void onUserLoggedOut();

    void start();
    void stop();

signals:
    void notificationTriggered(const QString &title, const QString &message, int noteId);

private slots:
    void checkNotifications();

private:
    void loadAndScheduleNotifications();

private:
    Database *m_db;
    QTimer *m_checkTimer;
    int m_currentUserId;
};

#endif // NOTIFICATIONMANAGER_H
