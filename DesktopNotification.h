#ifndef DESKTOPNOTIFICATION_H
#define DESKTOPNOTIFICATION_H

#include <QObject>
#include <QString>
#include <QSystemTrayIcon>
#include <QTimer>

class DesktopNotification : public QObject
{
    Q_OBJECT

public:
    explicit DesktopNotification(QObject *parent = nullptr);
    ~DesktopNotification();

    Q_INVOKABLE void showNotification(const QString &title, const QString &message, int notificationId = 0);
    Q_INVOKABLE void cancelNotification(int notificationId);

signals:
    void notificationClicked(int notificationId);

private slots:
    void onTrayIconActivated(QSystemTrayIcon::ActivationReason reason);
    void showNextNotification();

private:
    QSystemTrayIcon *m_trayIcon;
    QTimer *m_notificationTimer;
    QList<QPair<QString, QString>> m_notificationQueue;
    bool m_trayIconVisible;

    void setupTrayIcon();
    void showTrayMessage(const QString &title, const QString &message);
};

#endif // DESKTOPNOTIFICATION_H
