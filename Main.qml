import QtQuick 6.0
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.0
import QtQuick.Controls.Material 6.0
import QtQuick.Window 6.0

ApplicationWindow {
    id: window
    visible: true
    title: qsTr("Щоденник — Вхід / Реєстрація")
    Material.theme: Material.Light
    Material.background: window.backgroundColor
    width: stack.currentItem ? stack.currentItem.implicitWidth : 500
    height: 720
    property color accentColor: Material.color(Material.Indigo)
    property color backgroundColor: "#BBDEFB"
    property color currentTextColor: "#000000"

    Dialog {
        id: dialog
        width: 350
        modal: true
        property bool isError: false
        title: dialog.isError ? qsTr("Помилка") : qsTr("Повідомлення")

        Material.background: "#FFFFFF"

        contentItem: Frame {
            anchors.fill: parent
            background: Rectangle { color: "#FFFFFF" }
            padding: 15

            ColumnLayout {
                id: contentLayout
                spacing: 15
                anchors.fill: parent

                Label {
                    id: messageText
                    text: ""
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: dialog.isError ? Material.color(Material.Red, Material.Shade800) : "#000000"
                    font.pixelSize: 14
                    font.family: "Roboto"
                }
            }
        }

        footer: DialogButtonBox {
            id: footerBox
            standardButtons: DialogButtonBox.Ok
            onAccepted: dialog.close()
        }

        function show(message, isErrorMessage) {
            messageText.text = message
            dialog.isError = isErrorMessage
            dialog.open()
        }
    }

    Component {
        id: newNotePage
        Page {
            implicitWidth: 500
            implicitHeight: 720

            property StackView stackView: null
            property var dialog: null
            property int userId: -1
            property var dbManager: null
            property var notesModel: null

            property var taskTypeModel: []
            property var priorityModel: []
            property var repeatOptionModel: []

            Component.onCompleted: {
                if (dbManager) {
                    taskTypeModel = dbManager.getTaskTypes()
                    priorityModel = dbManager.getPriorities()
                    repeatOptionModel = dbManager.getRepeatOptions()
                }
                taskTypeComboBox.currentIndex = -1
                priorityComboBox.currentIndex = -1
                repeatOptionComboBox.currentIndex = 0
            }

            Material.background: window.backgroundColor || "#FFFFFF"

            header: ToolBar {
                Material.background: window.accentColor || Material.color(Material.Indigo)

                RowLayout {
                    anchors.fill: parent
                    ToolButton {
                        contentItem: Label {
                            text: qsTr("👈");
                            font.pixelSize: 24
                            color: "white"
                            font.family: "Roboto"
                        }
                        onClicked: stackView.pop()
                    }
                    Label {
                        text: qsTr("Створення нового запису")
                        font.pixelSize: 20
                        color: "white"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Roboto"
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                Frame {
                    width: parent.width
                    padding: 20
                    ColumnLayout {
                        width: parent.width - padding * 2
                        spacing: 15

                        Label {
                            text: qsTr("Заголовок:");
                            font.pixelSize: 16
                            color: window.currentTextColor
                            font.family: "Roboto"
                        }
                        TextField {
                            id: titleField
                            placeholderText: qsTr("Введіть заголовок запису")
                            Layout.fillWidth: true
                            font.pixelSize: 18
                            font.family: "Roboto"
                            color: window.currentTextColor
                            horizontalAlignment: TextInput.AlignHCenter
                        }

                        Label {
                            text: qsTr("Дата виконання:");
                            font.pixelSize: 16;
                            Layout.topMargin: 5
                            color: window.currentTextColor
                            font.family: "Roboto"
                        }
                        TextField {
                            id: executionDateField
                            placeholderText: qsTr("дд.мм.рррр")
                            Layout.fillWidth: true
                            font.pixelSize: 18
                            font.family: "Roboto"
                            color: window.currentTextColor
                            horizontalAlignment: TextInput.AlignHCenter
                        }

                        Label {
                            text: qsTr("Тип завдання:");
                            font.pixelSize: 16;
                            Layout.topMargin: 5
                            color: window.currentTextColor
                            font.family: "Roboto"
                        }
                        ComboBox {
                            id: taskTypeComboBox
                            Layout.fillWidth: true
                            model: taskTypeModel
                            textRole: "name"
                            valueRole: "id"
                            currentIndex: -1
                            property string placeholderTextValue: qsTr("Оберіть тип завдання")
                            displayText: currentIndex < 0 ? placeholderTextValue : currentText
                            font.family: "Roboto"
                            contentItem: Text {
                                text: taskTypeComboBox.displayText
                                font: taskTypeComboBox.font
                                color: taskTypeComboBox.currentIndex < 0 ? Material.color(Material.Grey, Material.Shade600) : window.currentTextColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Label {
                            text: qsTr("Повторювати:");
                            font.pixelSize: 16;
                            Layout.topMargin: 5
                            color: window.currentTextColor
                            font.family: "Roboto"
                        }
                        ComboBox {
                            id: repeatOptionComboBox
                            Layout.fillWidth: true
                            model: repeatOptionModel
                            textRole: "name"
                            valueRole: "id"
                            currentIndex: 0
                            property string placeholderTextValue: qsTr("Оберіть період повтору")
                            displayText: currentIndex < 0 ? placeholderTextValue : currentText
                            font.family: "Roboto"
                            contentItem: Text {
                                text: repeatOptionComboBox.displayText
                                font: repeatOptionComboBox.font
                                color: repeatOptionComboBox.currentIndex < 0 ? Material.color(Material.Grey, Material.Shade600) : window.currentTextColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Label {
                            text: qsTr("Пріоритет:");
                            font.pixelSize: 16;
                            Layout.topMargin: 5
                            color: window.currentTextColor
                            font.family: "Roboto"
                        }
                        ComboBox {
                            id: priorityComboBox
                            Layout.fillWidth: true
                            model: priorityModel
                            textRole: "name"
                            valueRole: "id"
                            currentIndex: -1
                            property string placeholderTextValue: qsTr("Оберіть пріоритет")
                            displayText: currentIndex < 0 ? placeholderTextValue : currentText
                            font.family: "Roboto"
                            contentItem: Text {
                                text: priorityComboBox.displayText
                                font: priorityComboBox.font
                                color: priorityComboBox.currentIndex < 0 ? Material.color(Material.Grey, Material.Shade600) : window.currentTextColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Label {
                            text: qsTr("Тип діяльності:");
                            font.pixelSize: 16;
                            Layout.topMargin: 5
                            color: window.currentTextColor
                            font.family: "Roboto"
                        }
                        TextField {
                            id: activityField
                            placeholderText: qsTr("Введіть тип діяльності")
                            Layout.fillWidth: true
                            font.pixelSize: 16
                            font.family: "Roboto"
                            color: window.currentTextColor
                            horizontalAlignment: TextInput.AlignHCenter
                        }

                        Label {
                            text: qsTr("Зміст запису:");
                            font.pixelSize: 16;
                            Layout.topMargin: 5
                            color: window.currentTextColor
                            font.family: "Roboto"
                        }
                        TextArea {
                            id: contentArea
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            placeholderText: qsTr("Введіть деталі вашого запису...")
                            font.family: "Roboto"
                            color: window.currentTextColor
                        }

                        Button {
                            text: qsTr("Зберегти запис")
                            Layout.fillWidth: true
                            Layout.topMargin: 10
                            Material.background: window.accentColor || Material.color(Material.Green, Material.Shade500)

                            onClicked: {
                                var activityValue = activityField.text.trim();
                                var executionDateRaw = executionDateField.text.trim();
                                var executionDateValue = "";

                                if (executionDateRaw !== "") {
                                    var dateRegex = /^(0[1-9]|[12]\d|3[01])\.(0[1-9]|1[0-2])\.(\d{4})$/;
                                    var dateMatch = executionDateRaw.match(dateRegex);

                                    if (dateMatch) {
                                        var day = parseInt(dateMatch[1]);
                                        var month = parseInt(dateMatch[2]);
                                        var year = parseInt(dateMatch[3]);

                                        if (day === 31 && (month === 4 || month === 6 || month === 9 || month === 11)) {
                                            dialog.show(qsTr("У %1 місяці може бути максимум 30 днів.").arg(month), true);
                                            return;
                                        }
                                        if (month === 2) {
                                            var isLeap = (year % 400 === 0) || (year % 4 === 0 && year % 100 !== 0);
                                            if (day > 29 || (day === 29 && !isLeap)) {
                                                dialog.show(qsTr("Лютий %1 року має максимум %2 днів.").arg(year).arg(isLeap ? 29 : 28), true);
                                                return;
                                            }
                                        }

                                        executionDateValue = year + '-' + dateMatch[2] + '-' + dateMatch[1];
                                    } else {
                                        dialog.show(qsTr("Введіть дату у форматі ДД.ММ.РРРР. Переконайтеся, що дні та місяці вказані коректно."), true);
                                        return;
                                    }
                                }

                                if (executionDateValue !== "") {
                                    var today = new Date();
                                    var execDate = new Date(executionDateValue + 'T00:00:00');
                                    today.setHours(0, 0, 0, 0);

                                    // Порівнюємо дати, ігноруючи час, використовуючи лише рік, місяць і день
                                    if (execDate < today) {
                                         // Якщо дата виконання минула (використовуючи date.getTime())
                                        if (dialog) dialog.show(qsTr("Введена дата виконання вже минула."), true);
                                        return;
                                    }
                                }

                                if (titleField.text.trim() === "" || contentArea.text.trim() === "" ||
                                            priorityComboBox.currentIndex < 0 || taskTypeComboBox.currentIndex < 0 ||
                                            activityValue === "") {
                                    if (dialog) dialog.show(qsTr("Будь ласка, заповніть усі обов'язкові поля."), true)
                                    return
                                }

                                if (userId <= 0) {
                                    if (dialog) dialog.show(qsTr("Критична помилка: Ідентифікатор користувача не знайдено."), true);
                                    return;
                                }

                                var newNote = {
                                    "title": titleField.text,
                                    "content": contentArea.text,
                                    "executionDate": executionDateValue,
                                    "taskType": taskTypeComboBox.currentText,
                                    "priority": priorityComboBox.currentText,
                                    "activityType": activityValue,
                                    "repeatOption": repeatOptionComboBox.currentText
                                };
                                var newId = 0;
                                if (dbManager) {
                                    var result = dbManager.addNote(userId, newNote);
                                    if (result !== null && result !== undefined && result !== 0) {
                                        newId = parseInt(result);
                                    }
                                }
                                if (newId > 0) {
                                    titleField.clear();
                                    contentArea.clear();
                                    executionDateField.clear();
                                    activityField.clear();
                                    priorityComboBox.currentIndex = -1;
                                    taskTypeComboBox.currentIndex = -1;
                                    repeatOptionComboBox.currentIndex = 0;
                                    stackView.pop()
                                    if (stackView.currentItem && stackView.currentItem.loadNotes) {
                                        stackView.currentItem.loadNotes();
                                    }
                                    if (dialog) dialog.show(qsTr("Запис успішно збережено!"), false)
                                } else {
                                    if (dialog) dialog.show(qsTr("Помилка збереження запису в базу даних."), true)
                                }
                            }
                        }

                        Button {
                            text: qsTr("Скасувати")
                            Layout.fillWidth: true
                            Material.background: Material.color(Material.Grey, Material.Shade500)
                            onClicked: stackView.pop()
                        }
                    }
                }
            }
        }
    }
    Component {
        id: noteDetailPage
        Page {
            implicitWidth: 500
            implicitHeight: 720

            property StackView stackView: null
            property var noteData: null

            Material.background: window.backgroundColor || "#FFFFFF"

            function formatDbDate(dbDate) {
                if (!dbDate || typeof dbDate !== 'string' || dbDate.length !== 10 || dbDate.indexOf('-') === -1) return dbDate;
                var parts = dbDate.split('-');
                return parts[2] + '.' + parts[1] + '.' + parts[0];
            }

            header: ToolBar {
                Material.background: window.accentColor || Material.color(Material.Indigo)

                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    ToolButton {
                        contentItem: Label {
                            text: qsTr("👈");
                            font.pixelSize: 24
                            color: "white"
                            font.family: "Roboto"
                        }
                        onClicked: stackView.pop()
                    }
                    Label {
                        text: noteData ? noteData.title : qsTr("Деталі запису")
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        color: "white"
                        font.family: "Roboto"
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                Frame {
                    width: parent.width
                    padding: 20
                    ColumnLayout {
                        width: parent.width - padding * 2
                        spacing: 10

                        Label {
                            text: qsTr("Дата створення: ") + (noteData ? formatDbDate(noteData.created_date) : "");
                            font.pixelSize: 14;
                            color: window.currentTextColor || Material.color(Material.Grey, Material.Shade700)
                            font.family: "Roboto"
                        }
                        Label {
                            text: qsTr("Час створення: ") + (noteData ? noteData.creation_time : "");
                            font.pixelSize: 14;
                            color: window.currentTextColor || Material.color(Material.Grey, Material.Shade700)
                            font.family: "Roboto"
                        }
                        Label {
                            text: qsTr("Виконати до: ") + (noteData && noteData.executionDate ? formatDbDate(noteData.executionDate) : qsTr("Не вказано"));
                            font.pixelSize: 14;
                            font.bold: true;
                            color: window.accentColor || Material.color(Material.Indigo, Material.Shade700)
                            font.family: "Roboto"
                        }
                        Label {
                            text: qsTr("Повторювати: ") + (noteData && noteData.repeatOption ? noteData.repeatOption : qsTr("Ніколи"));
                            font.pixelSize: 14;
                            color: window.currentTextColor || Material.color(Material.Teal, Material.Shade700)
                            font.family: "Roboto"
                        }
                        Label {
                            text: qsTr("Тип завдання: ") + (noteData ? noteData.taskType : "");
                            font.pixelSize: 14
                            color: window.currentTextColor || Material.color(Material.Grey, Material.Shade800)
                            font.family: "Roboto"
                        }
                        Label {
                            text: qsTr("Пріоритет: ") + (noteData ? noteData.priority : "");
                            font.pixelSize: 14;
                            color: noteData ? (
                                noteData.priority === qsTr("Висока") ? Material.color(Material.Red) :
                                noteData.priority === qsTr("Середня") ? Material.color(Material.Blue) :
                                noteData.priority === qsTr("Низька") ? Material.color(Material.Green) : window.currentTextColor
                            ) : window.currentTextColor
                            font.family: "Roboto"
                        }
                        Label {
                            text: qsTr("Тип діяльності: ") + (noteData ? noteData.activityType : "");
                            font.pixelSize: 14
                            color: window.currentTextColor || Material.color(Material.Grey, Material.Shade800)
                            font.family: "Roboto"
                        }

                        Rectangle {
                            Layout.fillWidth: true;
                            height: 1;
                            color: Material.color(Material.Grey, Material.Shade300);
                            Layout.topMargin: 10;
                            Layout.bottomMargin: 10
                        }

                        Label {
                            text: qsTr("Опис:");
                            font.pixelSize: 16;
                            font.bold: true;
                            color: window.currentTextColor || Material.color(Material.Grey, Material.Shade800)
                            font.family: "Roboto"
                        }

                        Rectangle {
                            id: detailContentContainer
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            color: Material.color(Material.Grey, Material.Shade100);
                            radius: 8;
                            border.width: 1;
                            border.color: Material.color(Material.Grey, Material.Shade300);

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 1
                                contentHeight: detailContentLabel.height + 20
                                clip: true

                                Label {
                                    id: detailContentLabel
                                    text: noteData ? noteData.content : ""
                                    width: parent.width - 20
                                    wrapMode: Text.WordWrap
                                    font.pixelSize: 16
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.top: parent.top
                                    anchors.topMargin: 10
                                    color: window.currentTextColor || Material.color(Material.Grey, Material.Shade800)
                                    font.family: "Roboto"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Component {
        id: diaryContent
        Page {
            id: diaryPage
            implicitWidth: 500
            implicitHeight: 720

            ListModel {
                id: notesModel
            }

            ListModel {
                id: weekNotesModel
            }
            property string userName: qsTr("Користувач")
            property int currentUserId: -1
            property var dbManager: null
            readonly property StackView stackRef: stack
            readonly property var loginPageRef: loginPage
            readonly property var dialogRef: dialog
            property int currentView: 0
            property var currentWeekStart: dateHelper.getStartOfWeek(new Date())
            property var todayDate: new Date()
            property int accentColorId: 1
            property int backgroundColorId: 1
            property int textColorId: 1
            property int fontFamilyId: 1
            QtObject {
                id: dateHelper
                function getStartOfWeek(date) {
                    var d = new Date(date.getTime());
                    var day = d.getDay();
                    var diff = d.getDate() - day + (day === 0 ? -6 : 1);
                    d.setDate(diff);
                    d.setHours(0, 0, 0, 0);
                    return d;
                }

                function addWeeks(date, weeks) {
                    var d = new Date(date.getTime());
                    d.setDate(d.getDate() + weeks * 7);
                    return d;
                }

                function formatDate(date) {
                    var dd = date.getDate();
                    var mm = date.getMonth() + 1;
                    var yyyy = date.getFullYear();
                    if (dd < 10) dd = '0' + dd;
                    if (mm < 10) mm = '0' + mm;
                    return dd + '.' + mm + '.' + yyyy;
                }

                function getDayName(dayIndex) {
                    var days = [qsTr("Нд"), qsTr("Пн"), qsTr("Вт"), qsTr("Ср"), qsTr("Чт"), qsTr("Пт"), qsTr("Сб")];
                    return days[dayIndex];
                }

                function getDaysForWeek(startDate) {
                    var days = [];
                    var current = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
                    for (var i = 0; i < 7; i++) {
                        days.push(new Date(current.getTime()));
                        current.setDate(current.getDate() + 1);
                    }
                    return days;
                }
            }

            function formatDbDate(dbDate) {
                if (!dbDate || typeof dbDate !== 'string' || dbDate.length !== 10 || dbDate.indexOf('-') === -1) return dbDate;
                var parts = dbDate.split('-');
                return parts[2] + '.' + parts[1] + '.' + parts[0];
            }

            function loadNotes() {
                if (dbManager && diaryPage.currentUserId > 0) {
                    var allNotes = dbManager.getNotesForUser(diaryPage.currentUserId);

                    if (currentView === 0) {
                        notesModel.clear();
                        for (var i = 0; i < allNotes.length; i++) {
                            notesModel.append(allNotes[i]);
                        }
                    } else if (currentView === 1) {
                        weekNotesModel.clear();

                        var start = diaryPage.currentWeekStart;
                        var end = dateHelper.addWeeks(start, 1);

                        var startISO = start.toISOString().split('T')[0];
                        var endISO = end.toISOString().split('T')[0];

                        var filteredNotes = [];
                        for (var j = 0; j < allNotes.length; j++) {
                            var note = allNotes[j];
                            if (note.executionDate && note.executionDate !== "") {
                                var noteDate = note.executionDate.toString().substring(0, 10);
                                if (noteDate >= startISO && noteDate < endISO) {
                                    filteredNotes.push(note);
                                }
                            }
                        }
                        var groupedNotes = {};
                        var todayDate = new Date();
                        var weekDays = dateHelper.getDaysForWeek(start);
                        for (var k = 0; k < 7; k++) {
                            var dayDate = weekDays[k];
                            var dayISO = dayDate.toISOString().split('T')[0];

                            groupedNotes[dayISO] = {
                                date: dayDate,
                                notes: []
                            };
                        }
                        for (let l = 0; l < filteredNotes.length; l++) {
                            let note = filteredNotes[l];
                            var noteDateKey = "";

                            if (note.executionDate && typeof note.executionDate === 'string' && note.executionDate.length >= 10) {
                                noteDateKey = note.executionDate.substring(0, 10);
                            } else {
                                console.error("Нотатка має некоректний executionDate:", note.title);
                                continue;
                            }

                            if (groupedNotes[noteDateKey]) {
                                groupedNotes[noteDateKey].notes.push(note);
                            } else {
                                console.warn("Нотатка знайдена, але поза діапазоном груп поточного тижня: ", noteDateKey, note.title);
                            }
                        }
                        weekNotesModel.clear();

                        var sortedKeys = Object.keys(groupedNotes).sort();

                        for (var keyIndex = 0; keyIndex < sortedKeys.length; keyIndex++) {
                            var key = sortedKeys[keyIndex];
                            if (groupedNotes.hasOwnProperty(key)) {
                                weekNotesModel.append({
                                    date: groupedNotes[key].date,
                                    dayName: dateHelper.getDayName(groupedNotes[key].date.getDay()),
                                    notes: groupedNotes[key].notes,
                                    isToday: groupedNotes[key].date.toDateString() === todayDate.toDateString()
                                });
                            }
                        }
                    }
                }
            }
            function goToPreviousWeek() {
                diaryPage.currentWeekStart = dateHelper.addWeeks(diaryPage.currentWeekStart, -1);
                loadNotes();
            }

            function goToNextWeek() {
                diaryPage.currentWeekStart = dateHelper.addWeeks(diaryPage.currentWeekStart, 1);
                loadNotes();
            }

            function saveSettings() {
                if (dbManager && currentUserId > 0) {
                    var accentId = dbManager.getColorIdByHex("accent_colors", window.accentColor);
                    var backgroundId = dbManager.getColorIdByHex("background_colors", window.backgroundColor);
                    var textId = dbManager.getColorIdByHex("text_colors", window.currentTextColor);
                    var fontId = 1;

                    if (accentId <= 0) {
                        dialogRef.show(qsTr("Помилка: Не вдалося знайти ID для акцентного кольору: ") + window.accentColor, true);
                        return;
                    }
                    if (backgroundId <= 0) {
                        dialogRef.show(qsTr("Помилка: Не вдалося знайти ID для фонового кольору: ") + window.backgroundColor, true);
                        return;
                    }
                    if (textId <= 0) {
                        dialogRef.show(qsTr("Помилка: Не вдалося знайти ID для кольору тексту: ") + window.currentTextColor, true);
                        return;
                    }


                    if (dbManager.saveUserSettings(currentUserId, accentId, backgroundId, textId)) {
                        diaryPage.accentColorId = accentId;
                        diaryPage.backgroundColorId = backgroundId;
                        diaryPage.textColorId = textId;
                        diaryPage.fontFamilyId = fontId;
                    } else {
                        dialogRef.show(qsTr("Помилка збереження налаштувань у базі даних."), true);
                    }
                }
            }

            Component.onCompleted: {
                if (diaryPage.currentUserId > 0) {
                    loadNotes();
                } else {
                    console.error("Помилка: diaryContent завантажено без дійсного currentUserId.")
                }
            }
            ColumnLayout {
                id: mainLayout
                anchors.fill: parent

                ToolBar {
                    id: diaryToolBar
                    contentHeight: 60
                    Layout.fillWidth: true
                    Material.background: window.accentColor || Material.color(Material.Indigo)

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                Label {
                                    text: qsTr("Ваш щоденник")
                                    font.pixelSize: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    font.family: "Roboto"
                                    color: "white"
                                }
                                TextField {
                                    id: searchField
                                    placeholderText: qsTr("Пошук (Назва/Дата)")
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    background: Rectangle { color: Material.color(Material.Grey, Material.Shade200); radius: 5 }
                                    font.family: "Roboto"
                                }
                                ToolButton {
                                    Layout.alignment: Qt.AlignVCenter
                                    contentItem: Label { text: "⚙️"; font.pixelSize: 24; color: "white" }
                                    onClicked: drawer.open()
                                }
                            }
                        }
                    }
                }
                TabBar {
                    id: viewTabBar
                    Layout.fillWidth: true
                    TabButton {
                        text: qsTr("Усі записи")
                        onClicked: {
                            diaryPage.currentView = 0;
                            diaryPage.loadNotes();
                        }
                        font.family: "Roboto"
                    }
                    TabButton {
                        text: qsTr("Планування тижня")
                        onClicked: {
                            diaryPage.currentView = 1;
                            diaryPage.currentWeekStart = dateHelper.getStartOfWeek(new Date());
                            diaryPage.loadNotes();
                        }
                        font.family: "Roboto"
                    }

                    currentIndex: diaryPage.currentView
                }
                RowLayout {
                    id: weekNavigator
                    visible: diaryPage.currentView === 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    spacing: 10
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    ToolButton {
                        contentItem: Label { text: qsTr("◀️"); font.pixelSize: 18 }
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: diaryPage.goToPreviousWeek()
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Тиждень: %1 - %2")
                            .arg(dateHelper.formatDate(diaryPage.currentWeekStart))
                            .arg(dateHelper.formatDate(dateHelper.addWeeks(diaryPage.currentWeekStart, 6)))
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "Roboto"
                        color: window.currentTextColor
                    }
                    ToolButton {
                        contentItem: Label { text: qsTr("▶️"); font.pixelSize: 18 }
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: diaryPage.goToNextWeek()
                    }
                }
                Loader {
                    id: contentLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    sourceComponent: diaryPage.currentView === 0 ? notesView : weekView
                    Component {
                        id: notesView
                        ColumnLayout {
                            id: notesLayout
                            width: parent.width
                            height: parent.height
                            ColumnLayout {
                                id: emptyState
                                visible: notesModel.count === 0
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 10
                                Label { text: qsTr("Нагадувань ще нема"); font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter; font.family: "Roboto"; color: window.currentTextColor }
                                Label { text: qsTr("Почніть вести свій щоденник"); font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter; font.family: "Roboto"; color: window.currentTextColor }
                                Button {
                                    text: qsTr("➕ Створити перший запис")
                                    Layout.alignment: Qt.AlignHCenter
                                    Material.background: window.accentColor
                                    Layout.topMargin: 20
                                    onClicked: Qt.callLater(function() {
                                        var noteInstance = newNotePage.createObject(stackRef, {
                                            stackView: stackRef,
                                            dialog: dialog,
                                            userId: diaryPage.currentUserId,
                                            dbManager: diaryPage.dbManager
                                        });
                                        if (noteInstance) {
                                            stackRef.push(noteInstance);
                                        }
                                    })
                                }
                            }
                            ListView {
                                id: notesList
                                visible: notesModel.count > 0
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: notesModel
                                spacing: 5
                                delegate: Control {
                                    id: noteDelegate
                                    height: 80
                                    width: notesList.width
                                    hoverEnabled: true
                                    clip: true
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: notesList.currentIndex === index ? Material.color(Material.Blue, Material.Shade100) : (noteDelegate.hovered ? Material.color(Material.Grey, Material.Shade50) : "white")
                                        radius: 8
                                        border.color: Material.color(Material.Grey, Material.Shade300)
                                        border.width: 1
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.rightMargin: 60
                                        onClicked: {
                                            notesList.currentIndex = index
                                            var detailInstance = noteDetailPage.createObject(stackRef, {
                                                stackView: stackRef,
                                                noteData: notesModel.get(index)
                                            });
                                            if (detailInstance) {
                                                stackRef.push(detailInstance);
                                            }
                                        }
                                    }
                                    RowLayout {
                                        spacing: 10
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Label { text: model.title; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight; font.family: "Roboto"; color: window.currentTextColor }
                                            RowLayout {
                                                Label {
                                                    text: formatDbDate(model.created_date);
                                                    font.pixelSize: 12;
                                                    color: Material.color(Material.Grey, Material.Shade700)
                                                    font.family: "Roboto"
                                                }
                                                Label {
                                                    text: " | " + model.priority;
                                                    font.pixelSize: 12;
                                                    color: model.priority === qsTr("Висока") ? Material.color(Material.Red, Material.Shade700) :
                                                           model.priority === qsTr("Середня") ? Material.color(Material.Blue, Material.Shade700) :
                                                           model.priority === qsTr("Низька") ? Material.color(Material.Green, Material.Shade700) : Material.color(Material.Grey, Material.Shade700)
                                                    font.family: "Roboto"
                                                }
                                                Label {
                                                    text: " | " + model.activityType;
                                                    font.pixelSize: 12;
                                                    color: Material.color(Material.Indigo, Material.Shade700)
                                                    font.family: "Roboto"
                                                }
                                            }
                                        }
                                        ToolButton {
                                            id: deleteButton
                                            Layout.alignment: Qt.AlignVCenter
                                            width: 40; height: 40
                                            visible: noteDelegate.hovered
                                            contentItem: Label {
                                                text: qsTr("🗑️")
                                                font.pixelSize: 24
                                                color: Material.color(Material.Red, Material.Shade700)
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            background: Rectangle {
                                                radius: 4;
                                                color: deleteButton.pressed ? Material.color(Material.Red, Material.Shade100) : "transparent";
                                            }
                                            onClicked: {
                                                var noteId = notesModel.get(index).id;
                                                if (noteId && noteId > 0) {
                                                    if (dbManager.deleteNote(noteId)) {
                                                        notesModel.remove(index);
                                                        dialog.show(qsTr("Запис успішно видалено."), false);
                                                    } else {
                                                        dialog.show(qsTr("Помилка видалення запису з бази даних!"), true);
                                                    }
                                                } else {
                                                    dialog.show(qsTr("Критична помилка: ID нотатки відсутній або недійсний."), true);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Component {
                        id: weekView
                        ListView {
                            id: weekList
                            anchors.fill: parent
                            anchors.topMargin: 10
                            anchors.bottomMargin: 76
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 15
                            model: weekNotesModel
                            ColumnLayout {
                                visible: weekNotesModel.count === 0 && !contentLoader.loading
                                anchors.centerIn: parent
                                spacing: 10
                                Label { text: qsTr("Нагадувань ще нема"); font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter; font.family: "Roboto"; color: window.currentTextColor }
                                Label { text: qsTr("Створіть нотатку з датою виконання, щоб побачити її тут."); font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter; font.family: "Roboto"; color: window.currentTextColor }
                            }

                            delegate: ColumnLayout {
                                width: weekList.width
                                spacing: 5

                                Label {
                                    text: qsTr("%1, %2").arg(dateHelper.getDayName(model.date.getDay())).arg(dateHelper.formatDate(model.date))
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: model.isToday ? Material.color(Material.Indigo) : window.currentTextColor
                                    font.family: "Roboto"
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: Material.color(Material.Grey, Material.Shade300)
                                }
                                Repeater {
                                    model: model.notes || []
                                    Layout.fillWidth: true

                                    delegate: Control {
                                        id: dayNoteDelegate
                                        height: 80
                                        width: parent.width
                                        hoverEnabled: true
                                        clip: true
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: dayNoteDelegate.hovered ? Material.color(Material.Grey, Material.Shade50) : "white"
                                            radius: 8
                                            border.color: Material.color(Material.Grey, Material.Shade300)
                                            border.width: 1
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            anchors.rightMargin: 60
                                            onClicked: {
                                                var detailInstance = noteDetailPage.createObject(stackRef, {
                                                    stackView: stackRef,
                                                    noteData: model
                                                });
                                                if (detailInstance) {
                                                    stackRef.push(detailInstance);
                                                }
                                            }
                                        }

                                        RowLayout {
                                            spacing: 10
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Label { text: model.title; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight; font.family: "Roboto"; color: window.currentTextColor }
                                                RowLayout {
                                                    Label {
                                                        text: formatDbDate(model.created_date);
                                                        font.pixelSize: 12;
                                                        color: Material.color(Material.Grey, Material.Shade700)
                                                        font.family: "Roboto"
                                                    }
                                                    Label {
                                                        text: " | " + model.priority;
                                                        font.pixelSize: 12;
                                                        color: model.priority === qsTr("Висока") ? Material.color(Material.Red, Material.Shade700) :
                                                               model.priority === qsTr("Середня") ? Material.color(Material.Blue, Material.Shade700) :
                                                               model.priority === qsTr("Низька") ? Material.color(Material.Green, Material.Shade700) : Material.color(Material.Grey, Material.Shade700)
                                                        font.family: "Roboto"
                                                    }
                                                    Label {
                                                        text: " | " + model.activityType;
                                                        font.pixelSize: 12;
                                                        color: Material.color(Material.Indigo, Material.Shade700)
                                                        font.family: "Roboto"
                                                    }
                                                }
                                            }
                                            ToolButton {
                                                id: deleteDayNoteButton
                                                Layout.alignment: Qt.AlignVCenter
                                                width: 40; height: 40
                                                visible: dayNoteDelegate.hovered
                                                contentItem: Label {
                                                    text: qsTr("🗑️"); font.pixelSize: 24; color: Material.color(Material.Red, Material.Shade700);
                                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                                }
                                                background: Rectangle {
                                                    radius: 4;
                                                    color: deleteDayNoteButton.pressed ? Material.color(Material.Red, Material.Shade100) : "transparent";
                                                }
                                                onClicked: {
                                                    var noteId = model.id;
                                                    if (noteId && noteId > 0) {
                                                        if (dbManager.deleteNote(noteId)) {
                                                            diaryPage.loadNotes();
                                                            dialog.show(qsTr("Запис успішно видалено."), false);
                                                        } else {
                                                            dialog.show(qsTr("Помилка видалення запису з бази даних!"), true);
                                                        }
                                                    } else {
                                                        dialog.show(qsTr("Критична помилка: ID нотатки відсутній або недійсний."), true);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                Label {
                                    visible: Repeater.count === 0
                                    text: qsTr("Немає запланованих справ на цей день.")
                                    font.pixelSize: 12
                                    color: Material.color(Material.Grey)
                                    Layout.leftMargin: 10
                                    font.family: "Roboto"
                                }
                            }
                        }
                    }
                }
            }
            Drawer {
                id: drawer
                edge: Qt.RightEdge
                width: 280
                height: parent.height
                Material.background: window.backgroundColor || "#FFFFFF"

                ColumnLayout {
                    width: parent.width
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 20
                    Rectangle {
                        id: avatarWrapper
                        Layout.preferredWidth: 80; Layout.preferredHeight: 80
                        Layout.alignment: Qt.AlignHCenter
                        radius: avatarWrapper.width / 2
                        clip: true
                        Label {
                            text: "👤"
                            font.pixelSize: 60
                            anchors.centerIn: parent
                            font.family: "Roboto"
                            color: window.currentTextColor
                        }
                        MouseArea { anchors.fill: parent; onClicked: dialog.show(qsTr("Виберіть нове фото аватара..."), false) }
                    }
                    Label {
                        text: diaryPage.userName
                        font.pixelSize: 16;
                        font.bold: true;
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 5
                        font.family: "Roboto"
                        color: window.currentTextColor
                    }

                    Label { text: qsTr("Налаштування щоденника"); font.pixelSize: 18; font.bold: true; Layout.topMargin: 20; font.family: "Roboto"; color: window.currentTextColor }
                    Label { text: qsTr("Колір кнопок/шапки:"); font.bold: true; font.family: "Roboto"; color: window.currentTextColor }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Repeater {
                            model: [
                                Material.color(Material.Indigo),
                                Material.color(Material.Red),
                                Material.color(Material.Green),
                                Material.color(Material.Teal),
                                Material.color(Material.Orange),
                                Material.color(Material.BlueGrey)
                            ]
                            delegate: ToolButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                background: Rectangle {
                                    anchors.fill: parent
                                    radius: 15
                                    color: modelData
                                    border.width: window.accentColor === modelData ? 3 : 1
                                    border.color: window.accentColor === modelData ? Material.color(Material.Grey, Material.Shade900) : Material.color(Material.Grey, Material.Shade400)
                                }
                                onClicked: {
                                    window.accentColor = modelData;
                                    diaryPage.saveSettings();
                                }
                            }
                        }
                    }
                    Label { text: qsTr("Фоновий колір (Пастель):"); font.bold: true; Layout.topMargin: 15; font.family: "Roboto"; color: window.currentTextColor }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Repeater {
                            model: ["#FFFFFF", "#FFF9C4", "#BBDEFB", "#F8E0F7", "#CFEFCF", "#FBE4D8"]
                            delegate: ToolButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                background: Rectangle {
                                    anchors.fill: parent
                                    radius: 15
                                    color: modelData
                                    border.width: window.backgroundColor === modelData ? 3 : 1
                                    border.color: window.backgroundColor === modelData ? Material.color(Material.Grey, Material.Shade900) : Material.color(Material.Grey, Material.Shade400)
                                }
                                onClicked: {
                                    window.backgroundColor = modelData;
                                    diaryPage.saveSettings();
                                }
                            }
                        }
                    }

                    Label { text: qsTr("Колір основного тексту:"); font.bold: true; Layout.topMargin: 15; font.family: "Roboto"; color: window.currentTextColor }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Repeater {
                            model: ["#000000", "#555555", "#FF0000", "#008000", "#0000FF", "#800080"]
                            delegate: ToolButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                background: Rectangle {
                                    anchors.fill: parent
                                    radius: 15
                                    color: modelData
                                    border.width: window.currentTextColor === modelData ? 3 : 1
                                    border.color: window.currentTextColor === modelData ? Material.color(Material.Indigo) : Material.color(Material.Grey, Material.Shade400)
                                }
                                onClicked: {
                                    window.currentTextColor = modelData;
                                    diaryPage.saveSettings();
                                }
                            }
                        }
                    }

                    Button {
                        text: qsTr("Вийти з акаунта")
                        Layout.fillWidth: true
                        Layout.topMargin: 50
                        Material.background: Material.color(Material.Red)
                        onClicked: {
                            drawer.close();
                            notesModel.clear();
                            diaryPage.currentUserId = -1;
                            dialog.show(qsTr("Вихід успішний. Повернення до сторінки входу."), false);
                            Qt.callLater(function() {
                                if (stackRef && loginPageRef) {
                                    stackRef.replace(loginPageRef);
                                } else {
                                    console.error("Помилка: StackView або loginPageRef недоступні для повернення.")
                                }
                            });
                        }
                    }
                }
            }
            Button {
                id: fab
                text: "➕"
                font.pixelSize: 24
                width: 56
                height: 56
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 20
                anchors.bottomMargin: 20
                visible: diaryPage.currentView === 1 || notesModel.count > 0
                background: Rectangle {
                    radius: fab.width / 2
                    color: window.accentColor || Material.color(Material.Indigo)
                }
                Material.foreground: "white"
                onClicked: Qt.callLater(function() {
                    var noteInstance = newNotePage.createObject(stackRef, {
                        stackView: stackRef,
                        dialog: dialog,
                        userId: diaryPage.currentUserId,
                        dbManager: diaryPage.dbManager
                    });
                    if (noteInstance) {
                        stackRef.push(noteInstance);
                    }
                })
            }
        }
    }
    Component {
        id: registerPage
        Page {
            title: qsTr("Реєстрація")
            implicitWidth: 500
            implicitHeight: 720
            Material.background: "#FFFFFF"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16
                width: Math.min(parent.width * 0.85, 400)

                Label {
                    text: qsTr("Створення акаунту")
                    font.pixelSize: 22
                    Layout.alignment: Qt.AlignHCenter
                    font.family: "Roboto"
                    color: "#000000"
                }

                TextField {
                    id: nameField
                    placeholderText: qsTr("Ім'я")
                    Layout.fillWidth: true
                    font.family: "Roboto"
                    color: "#000000"
                }

                TextField {
                    id: regEmail
                    placeholderText: qsTr("Електронна пошта")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    font.family: "Roboto"
                    color: "#000000"
                }

                TextField {
                    id: regPass1
                    placeholderText: qsTr("Пароль")
                    echoMode: passwordVisible1.checked ? TextInput.Normal : TextInput.Password
                    Layout.fillWidth: true
                    rightPadding: regPass1ShowBtn.width + regPass1ShowBtn.anchors.rightMargin * 2
                    font.family: "Roboto"
                    color: "#000000"

                    ToolButton {
                        id: regPass1ShowBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        width: 30
                        height: parent.height
                        implicitWidth: 30

                        contentItem: CheckBox {
                            id: passwordVisible1
                            checked: false
                            indicator: null
                            contentItem: Label {
                                text: passwordVisible1.checked ? "🔓" : "🔒"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                        }
                        onClicked: passwordVisible1.checked = !passwordVisible1.checked
                    }
                }

                TextField {
                    id: regPass2
                    placeholderText: qsTr("Підтвердіть пароль")
                    echoMode: passwordVisible2.checked ? TextInput.Normal : TextInput.Password
                    Layout.fillWidth: true
                    rightPadding: regPass2ShowBtn.width + regPass2ShowBtn.anchors.rightMargin * 2
                    font.family: "Roboto"
                    color: "#000000"

                    ToolButton {
                        id: regPass2ShowBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        width: 30
                        height: parent.height
                        implicitWidth: 30

                        contentItem: CheckBox {
                            id: passwordVisible2
                            checked: false
                            indicator: null
                            contentItem: Label {
                                text: passwordVisible2.checked ? "🔓" : "🔒"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                        }
                        onClicked: passwordVisible2.checked = !passwordVisible2.checked
                    }
                }

                Button {
                    text: qsTr("Зареєструватися")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Green)
                    font.family: "Roboto"
                    onClicked: {
                        var dbManagerRef = typeof dbManager !== 'undefined' ? dbManager : null;

                        if (nameField.text.trim() === "" || regEmail.text.trim() === "" || regPass1.text === "" || regPass2.text === "") {
                            dialog.show(qsTr("Будь ласка, заповніть усі поля."), true);
                            return
                        }

                        if (regEmail.text.indexOf("@") === -1) {
                            dialog.show(qsTr("Некоректно введена пошта."), true);
                            return
                        }

                        if (regPass1.text !== regPass2.text) {
                            dialog.show(qsTr("Паролі не співпадають."), true);
                            return
                        }

                        if (dbManagerRef) {
                            if (dbManagerRef.registerUser(nameField.text, regEmail.text, regPass1.text)) {
                                dialog.show(qsTr("Реєстрація успішна! Тепер ви можете увійти."), false)
                                Qt.callLater(function() { stack.replace(loginPage) })
                            } else {
                                dialog.show(qsTr("Помилка реєстрації. Можливо, користувач з таким email вже існує."), true)
                            }
                        } else {
                            dialog.show(qsTr("ПОМИЛКА: Об'єкт dbManager недоступний. Реєстрація неможлива."), true)
                        }
                    }
                }

                Button {
                    text: qsTr("Назад до входу")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Red)
                    font.family: "Roboto"
                    onClicked: stack.replace(loginPage)
                }
            }
        }
    }
    Component {
        id: loginPage
        Page {
            title: qsTr("Вхід")
            implicitWidth: 500
            implicitHeight: 720
            Material.background: "#FFFFFF"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16
                width: Math.min(parent.width * 0.85, 400)

                Label {
                    text: qsTr("Ласкаво просимо!")
                    font.pixelSize: 22
                    Layout.alignment: Qt.AlignHCenter
                    font.family: "Roboto"
                    color: "#000000"
                }

                TextField {
                    id: email
                    placeholderText: qsTr("Електронна пошта")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    font.family: "Roboto"
                    color: "#000000"
                }

                TextField {
                    id: password
                    placeholderText: qsTr("Пароль")
                    echoMode: loginPasswordVisible.checked ? TextInput.Normal : TextInput.Password
                    Layout.fillWidth: true
                    rightPadding: loginPasswordShowBtn.width + loginPasswordShowBtn.anchors.rightMargin * 2
                    font.family: "Roboto"
                    color: "#000000"

                    ToolButton {
                        id: loginPasswordShowBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        width: 30
                        height: parent.height
                        implicitWidth: 30

                        contentItem: CheckBox {
                            id: loginPasswordVisible
                            checked: false
                            indicator: null
                            contentItem: Label {
                                text: loginPasswordVisible.checked ? "🔓" : "🔒"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                        }
                        onClicked: loginPasswordVisible.checked = !loginPasswordVisible.checked
                    }
                }

                Button {
                    text: qsTr("Увійти")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Indigo)
                    font.family: "Roboto"
                    onClicked: {
                        var dbManagerRef = typeof dbManager !== 'undefined' ? dbManager : null;

                        if (email.text.trim() === "" || password.text === "") {
                            dialog.show(qsTr("Будь ласка, заповніть усі поля."), true);
                            return
                        }

                        if (email.text.indexOf("@") === -1) {
                            dialog.show(qsTr("Некоректно введена пошта."), true);
                            return
                        }

                        if (dbManagerRef) {
                            var userData = dbManagerRef.loginUser(email.text, password.text);

                            if (userData && userData.email) {
                                email.clear(); password.clear()

                                window.accentColor = userData.accentColor;
                                window.backgroundColor = userData.backgroundColor;
                                window.currentTextColor = userData.textColor;


                                var diaryInstance = diaryContent.createObject(stack, {
                                    userName: userData.name,
                                    userEmail: userData.email,
                                    currentUserId: userData.id,
                                    dbManager: dbManagerRef,
                                    accentColorId: userData.accentColorId,
                                    backgroundColorId: userData.backgroundColorId,
                                    textColorId: userData.textColorId,
                                    fontFamilyId: userData.fontFamilyId
                                });

                                if (diaryInstance) {
                                    diaryInstance.loadNotes();
                                    Qt.callLater(function() { stack.replace(diaryInstance); })
                                } else {
                                    dialog.show(qsTr("Критична помилка ініціалізації сторінки щоденника."), true);
                                }

                            } else {
                                dialog.show(qsTr("Невірний email або пароль."), true)
                            }
                        } else {
                            dialog.show(qsTr("ПОМИЛКА: Об'єкт dbManager недоступний. Увійти неможливо."), true)
                        }
                    }
                }

                Button {
                    text: qsTr("Реєстрація")
                    Layout.fillWidth: true
                    Material.background: Material.color(Material.Grey)
                    font.family: "Roboto"
                    onClicked: Qt.callLater(function() { stack.replace(registerPage) })
                }
            }
        }
    }
    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loginPage
    }
}
