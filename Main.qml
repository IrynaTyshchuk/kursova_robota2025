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
                    try {
                        taskTypeModel = dbManager.getTaskTypes()
                        priorityModel = dbManager.getPriorities()
                        repeatOptionModel = dbManager.getRepeatOptions()
                    } catch (e) {
                        console.error("Помилка завантаження допоміжних моделей з dbManager:", e)
                    }
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

                                var repeatOptionId = repeatOptionComboBox.currentIndex >= 0 ? repeatOptionComboBox.model[repeatOptionComboBox.currentIndex].id : 1;
                                var taskTypeId = taskTypeComboBox.currentIndex >= 0 ? taskTypeComboBox.model[taskTypeComboBox.currentIndex].id : -1;
                                var priorityId = priorityComboBox.currentIndex >= 0 ? priorityComboBox.model[priorityComboBox.currentIndex].id : -1;

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
                                    var todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
                                    var dateParts = executionDateValue.split('-');
                                    var execDate = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);

                                    if (execDate < todayStart) {
                                        if (dialog) dialog.show(qsTr("Введена дата виконання вже минула."), true);
                                        return;
                                    }
                                }

                                if (titleField.text.trim() === "" || contentArea.text.trim() === "" ||
                                            priorityComboBox.currentIndex < 0 || taskTypeComboBox.currentIndex < 0 ||
                                            activityValue === "") {
                                    if (dialog) dialog.show(qsTr("Будь ласка, заповніть усі обов'язкові поля (заголовок, зміст, пріоритет, тип завдання, діяльність)."), true)
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
                            text: qsTr("Час створення: ") + (noteData && noteData.created_time && noteData.created_time !== "" ? noteData.created_time : qsTr("Не вказано"));
                            font.pixelSize: 14;
                            color: window.currentTextColor || Material.color(Material.Grey, Material.Shade700)
                            font.family: "Roboto"
                        }
                        Label {
                            text: qsTr("Виконати до: ") + (noteData && noteData.execution_date && noteData.execution_date !== "" ? formatDbDate(noteData.execution_date) : qsTr("Не вказано"));
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
                    if (!date || isNaN(date.getTime())) return new Date();

                    var d = new Date(date.getFullYear(), date.getMonth(), date.getDate());
                    var day = d.getDay();
                    var diff = d.getDate() - day + (day === 0 ? -6 : 1);
                    d.setDate(diff);
                    return d;
                }

                function addWeeks(date, weeks) {
                    if (!date || isNaN(date.getTime())) return new Date();
                    var d = new Date(date.getTime());
                    d.setDate(d.getDate() + weeks * 7);
                    return d;
                }

                function addDays(date, days) {
                    if (!date || isNaN(date.getTime())) return new Date();
                    var d = new Date(date.getTime());
                    d.setDate(d.getDate() + days);
                    return d;
                }

                function formatDate(date) {
                    if (!date || isNaN(date.getTime())) return qsTr("---");

                    var dd = date.getDate();
                    var mm = date.getMonth() + 1;
                    var yyyy = date.getFullYear();
                    if (dd < 10) dd = '0' + dd;
                    if (mm < 10) mm = '0' + mm;
                    return dd + '.' + mm + '.' + yyyy;
                }

                function getIsoDateString(date) {
                    if (!date || isNaN(date.getTime())) return "";

                    var dd = date.getDate();
                    var mm = date.getMonth() + 1;
                    var yyyy = date.getFullYear();
                    if (dd < 10) dd = '0' + dd;
                    if (mm < 10) mm = '0' + mm;
                    return yyyy + '-' + mm + '-' + dd;
                }

                function getDaysForWeek(startDate) {
                    var days = [];
                    if (!startDate || isNaN(startDate.getTime())) return days;

                    var current = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
                    for (var i = 0; i < 7; i++) {
                        days.push(new Date(current.getTime()));
                        current.setDate(current.getDate() + 1);
                    }
                    return days;
                }

                function getDayNameById(dayId) {
                    var days = { 1: qsTr("Пн"), 2: qsTr("Вт"), 3: qsTr("Ср"), 4: qsTr("Чт"), 5: qsTr("Пт"), 6: qsTr("Сб"), 7: qsTr("Нд") };
                    return days[dayId] || qsTr("---");
                }

                function getDayIdFromDate(date) {
                    if (!date || isNaN(date.getTime())) return 0;

                    var dayIndex = date.getDay();
                    return dayIndex === 0 ? 7 : dayIndex;
                }
            }

            function formatDbDate(dbDate) {
                if (!dbDate || typeof dbDate !== 'string' || dbDate.length !== 10 || dbDate.indexOf('-') === -1) return dbDate;
                var parts = dbDate.split('-');
                return parts[2] + '.' + parts[1] + '.' + parts[0];
            }

            function loadNotes() {
                console.log("--- Starting loadNotes() for view:", diaryPage.currentView);
                if (dbManager && diaryPage.currentUserId > 0) {
                    var allNotes = dbManager.getNotesForUser(diaryPage.currentUserId);
                    console.log("Total notes fetched from DB:", allNotes.length);

                    if (currentView === 0) {
                        notesModel.clear();
                        for (var i = 0; i < allNotes.length; i++) {
                            notesModel.append(allNotes[i]);
                        }
                        console.log("Notes loaded into All Records view. Count:", notesModel.count);

                    } else if (currentView === 1) {
                        weekNotesModel.clear();

                        var start = diaryPage.currentWeekStart;
                        var end = dateHelper.addDays(start, 7);
                        var today = new Date();
                        today.setHours(0, 0, 0, 0);

                        var groupedDays = {};
                        var weekDays = dateHelper.getDaysForWeek(start);
                        console.log("Week start:", dateHelper.formatDate(start), " | Week end (exclusive):", dateHelper.formatDate(end));

                        for (var k = 0; k < 7; k++) {
                            var dayDate = weekDays[k];
                            var dayId = dateHelper.getDayIdFromDate(dayDate);
                            console.log(`Init Day [${k+1}]: ID=${dayId}, Name=${dateHelper.getDayNameById(dayId)}, Date=${dateHelper.formatDate(dayDate)}`);

                            var dayData = {
                                date: dayDate,
                                dayName: dateHelper.getDayNameById(dayId),
                                isToday: dayDate.toDateString() === today.toDateString(),
                                notesJson: "[]",
                                isEmpty: true
                            };
                            groupedDays[dayId] = dayData;
                        }

                        for (let l = 0; l < allNotes.length; l++) {
                            let note = allNotes[l];
                            var isRecurring = note.taskType === qsTr("Повторюване");
                            console.log(`Processing Note ${l + 1}: ${note.title} | Type: ${note.taskType} | Exec Date: ${note.execution_date}`);

                            if (note.execution_date && typeof note.execution_date === 'string' && note.execution_date.length >= 10) {
                                var noteExecutionDateISO = note.execution_date.substring(0, 10);
                                var noteExecutionDateObj = new Date(noteExecutionDateISO);
                                noteExecutionDateObj.setHours(0, 0, 0, 0);

                                var createdDateObj = new Date(note.created_date.substring(0, 10));
                                createdDateObj.setHours(0, 0, 0, 0);

                                if (isRecurring) {
                                    for (let dayIdCurrent = 1; dayIdCurrent <= 7; dayIdCurrent++) {
                                        var dayGroup = groupedDays[dayIdCurrent];
                                        if (!dayGroup) continue;

                                        var dayDateObj = dayGroup.date;

                                        if (!(dayDateObj.getTime() >= start.getTime() && dayDateObj.getTime() < end.getTime())) {
                                            continue;
                                        }

                                        var isAfterCreation = dayDateObj.getTime() >= createdDateObj.getTime();
                                        var isBeforeOrOnExecution = dayDateObj.getTime() <= noteExecutionDateObj.getTime();

                                        if (isAfterCreation && isBeforeOrOnExecution) {
                                            var clonedNote = JSON.parse(JSON.stringify(note));
                                            clonedNote.displayType = qsTr("Повтор");

                                            if (dayDateObj.toDateString() === createdDateObj.toDateString()) {
                                                clonedNote.displayType = qsTr("Початок Повтору");
                                            } else if (dayDateObj.toDateString() === noteExecutionDateObj.toDateString()) {
                                                clonedNote.displayType = qsTr("Кінець Повтору");
                                            }

                                            if (!dayGroup.notesArray) {
                                                dayGroup.notesArray = [];
                                            }
                                            dayGroup.notesArray.push(clonedNote);
                                            dayGroup.isEmpty = false;
                                            console.log(`     -> ADDED (Recurring) to day: ${dayGroup.dayName} (${dateHelper.formatDate(dayDateObj)})`);
                                        }
                                    }

                                } else {
                                    if (noteExecutionDateObj.getTime() >= start.getTime() && noteExecutionDateObj.getTime() < end.getTime()) {
                                        var executionDayIdForWeek = dateHelper.getDayIdFromDate(noteExecutionDateObj);

                                        if (groupedDays[executionDayIdForWeek]) {
                                            note.displayType = qsTr("Подія");

                                            if (!groupedDays[executionDayIdForWeek].notesArray) {
                                                groupedDays[executionDayIdForWeek].notesArray = [];
                                            }
                                            groupedDays[executionDayIdForWeek].notesArray.push(note);
                                            groupedDays[executionDayIdForWeek].isEmpty = false;
                                            console.log(`     -> ADDED (Single) to day: ${groupedDays[executionDayIdForWeek].dayName} (${dateHelper.formatDate(groupedDays[executionDayIdForWeek].date)})`);
                                        }
                                    }
                                }
                            }
                        }

                        var notesCount = 0;
                        for (var dayId = 1; dayId <= 7; dayId++) {
                            var dayData = groupedDays[dayId];
                            if (!dayData) continue;

                            if (dayData.notesArray && dayData.notesArray.length > 0) {
                                dayData.notesArray.sort(function(a, b) {
                                    return a.created_time.localeCompare(b.created_time);
                                });

                                dayData.notesJson = JSON.stringify(dayData.notesArray);
                                notesCount += dayData.notesArray.length;
                            } else {
                                dayData.notesJson = "[]";
                            }

                            weekNotesModel.append({
                                date: dayData.date,
                                dayName: dayData.dayName,
                                notesJson: dayData.notesJson,
                                isToday: dayData.isToday,
                                isEmpty: dayData.isEmpty
                            });
                        }
                        console.log("--- Load finished. Total tasks displayed:", notesCount);
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

                    if (accentId <= 0 || backgroundId <= 0 || textId <= 0) {
                        dialogRef.show(qsTr("Помилка: Не вдалося знайти ID для одного з вибраних кольорів. Перевірте базу даних."), true);
                        return;
                    }

                    // *** ЗМІНА: Використання глобальних об'єктів C++ без "window."
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

            // ==========================================================
            // ЛОГІКА ДЛЯ NOTIFICATION MANAGER
            // ==========================================================
            Component.onCompleted: {
                // *** ВИПРАВЛЕНО: Використання глобальних об'єктів C++ без "diaryPage." чи "window."
                if (diaryPage.currentUserId > 0) {
                    loadNotes();
                    // Звернення до глобального об'єкта C++
                    if (typeof notificationManager !== 'undefined' && notificationManager) {
                        notificationManager.onUserLoggedIn(currentUserId);
                        console.log("NotificationManager: User logged in, ID:", currentUserId);
                    }
                } else {
                    console.error("Помилка: diaryContent завантажено без дійсного currentUserId.")
                }
            }
            // ==========================================================

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
                                    contentItem: Label { text: "⚙️"; font.pixelSize: 24; color: "white"; font.family: "Roboto" }
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
                        contentItem: Label { text: qsTr("◀️"); font.pixelSize: 18; font.family: "Roboto" }
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: diaryPage.goToPreviousWeek()
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Тиждень: %1 - %2")
                            .arg(dateHelper.formatDate(diaryPage.currentWeekStart))
                            .arg(dateHelper.formatDate(dateHelper.addDays(diaryPage.currentWeekStart, 6)))
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "Roboto"
                        color: window.currentTextColor
                    }
                    ToolButton {
                        contentItem: Label { text: qsTr("▶️"); font.pixelSize: 18; font.family: "Roboto" }
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
                                                    text: model.execution_date ? (" | " + qsTr("Виконати до: ") + formatDbDate(model.execution_date)) : "";
                                                    font.pixelSize: 12;
                                                    color: Material.color(Material.Indigo, Material.Shade700);
                                                    font.family: "Roboto"
                                                }
                                            }
                                            RowLayout {
                                                Label {
                                                    text: model.priority;
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
                                            visible: noteDelegate && noteDelegate.hovered === true
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
                        ColumnLayout {
                            width: parent.width
                            height: parent.height

                            ListView {
                                id: weekList
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: weekNotesModel
                                spacing: 10
                                clip: true

                                delegate: ColumnLayout {
                                    id: dayDelegateRoot
                                    width: weekList.width
                                    spacing: 5

                                    property var dayDate: model.date
                                    property var dayName: model.dayName
                                    property var notesJson: model.notesJson
                                    property bool isToday: model.isToday || false
                                    property bool isEmpty: model.isEmpty || true

                                    property var dayNotes: {
                                        try {
                                            if (notesJson && notesJson !== "[]") {
                                                return JSON.parse(notesJson);
                                            }
                                        } catch (e) {
                                            console.error("Error parsing notes JSON:", e);
                                        }
                                        return [];
                                    }

                                    visible: dayName !== undefined && dayName !== ""

                                    Rectangle {
                                        id: dayHeader
                                        Layout.fillWidth: true
                                        height: 40
                                        Layout.margins: 5
                                        radius: 5
                                        color: isToday ? Material.color(Material.Yellow, Material.Shade200) : window.backgroundColor

                                        Label {
                                            text: dayName + ", " +
                                                    (dayDate ? dateHelper.formatDate(dayDate) : "---") +
                                                    (isToday ? " " + qsTr("(Сьогодні)") : "")
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: window.currentTextColor
                                            font.family: "Roboto"
                                            anchors.centerIn: parent
                                            leftPadding: 10
                                            rightPadding: 10
                                        }
                                    }

                                    Column {
                                        width: parent.width
                                        spacing: 5
                                        Layout.leftMargin: 15
                                        Layout.rightMargin: 15

                                        Rectangle {
                                            width: parent.width
                                            height: 40
                                            color: "transparent"
                                            visible: dayNotes.length === 0
                                            Label {
                                                anchors.centerIn: parent
                                                text: qsTr("Нотаток немає")
                                                color: Material.color(Material.Grey, Material.Shade500)
                                                font.pixelSize: 14
                                                font.family: "Roboto"
                                            }
                                        }

                                        Repeater {
                                            model: dayNotes

                                            delegate: Control {
                                                id: weekNoteDelegate
                                                height: 80
                                                width: parent.width
                                                hoverEnabled: true
                                                clip: true
                                                Layout.topMargin: 5
                                                Layout.bottomMargin: 5

                                                property var currentNote: modelData

                                                visible: currentNote !== undefined && currentNote !== null

                                                background: Rectangle {
                                                    anchors.fill: parent
                                                    color: (weekNoteDelegate.hovered ? Material.color(Material.Grey, Material.Shade50) : "white")
                                                    radius: 8
                                                    border.color: Material.color(Material.Grey, Material.Shade300)
                                                    border.width: 1
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    anchors.rightMargin: 60
                                                    enabled: currentNote !== undefined && currentNote !== null
                                                    onClicked: {
                                                        var detailInstance = noteDetailPage.createObject(stackRef, {
                                                            stackView: stackRef,
                                                            noteData: currentNote
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
                                                        Label {
                                                            text: currentNote ? currentNote.title : "";
                                                            font.pixelSize: 16;
                                                            font.bold: true;
                                                            Layout.fillWidth: true;
                                                            elide: Text.ElideRight;
                                                            font.family: "Roboto";
                                                            color: window.currentTextColor
                                                        }

                                                        RowLayout {
                                                            Label {
                                                                text: currentNote ? formatDbDate(currentNote.created_date) : "";
                                                                font.pixelSize: 12;
                                                                color: Material.color(Material.Grey, Material.Shade700)
                                                                font.family: "Roboto"
                                                            }
                                                            Label {
                                                                text: currentNote && currentNote.displayType ? (" | " + currentNote.displayType) : "";
                                                                font.pixelSize: 12;
                                                                color: Material.color(Material.Teal, Material.Shade700);
                                                                font.family: "Roboto"
                                                            }
                                                        }

                                                        RowLayout {
                                                            Label {
                                                                text: currentNote ? currentNote.priority : "";
                                                                font.pixelSize: 12;
                                                                color: currentNote && currentNote.priority === qsTr("Висока") ? Material.color(Material.Red, Material.Shade700) :
                                                                        currentNote && currentNote.priority === qsTr("Середня") ? Material.color(Material.Blue, Material.Shade700) :
                                                                        currentNote && currentNote.priority === qsTr("Низька") ? Material.color(Material.Green, Material.Shade700) : Material.color(Material.Grey, Material.Shade700)
                                                                font.family: "Roboto"
                                                            }
                                                            Label {
                                                                text: currentNote ? " | " + currentNote.activityType : "";
                                                                font.pixelSize: 12;
                                                                color: Material.color(Material.Indigo, Material.Shade700)
                                                                font.family: "Roboto"
                                                            }
                                                        }
                                                    }

                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } }
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

                        // ==========================================================
                        // КНОПКА ТЕСТУВАННЯ СПОВІЩЕНЬ
                        // ==========================================================
                        Button {
                            text: qsTr("Тест сповіщення")
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            Material.background: Material.color(Material.Blue, Material.Shade500)
                            onClicked: {
                                // *** ВИПРАВЛЕНО: Звернення до глобального desktopNotification ***
                                if (typeof desktopNotification !== 'undefined' && desktopNotification) {
                                    desktopNotification.showNotification(
                                        qsTr("Тестове сповіщення"),
                                        qsTr("Це тестове сповіщення від щоденника. ID: 123"),
                                        123
                                    );
                                } else {
                                    dialog.show(qsTr("ПОМИЛКА: Об'єкт desktopNotification недоступний."), true);
                                }
                            }
                        }
                        // ==========================================================

                        Button {
                            text: qsTr("Вийти з акаунта")

                            Layout.fillWidth: true
                            Layout.topMargin: 50
                            Material.background: Material.color(Material.Red)
                            onClicked: {
                                // *** ВИПРАВЛЕНО: Звернення до глобального notificationManager ***
                                if (typeof notificationManager !== 'undefined' && notificationManager) {
                                    notificationManager.onUserLoggedOut();
                                }
                                drawer.close();
                                notesModel.clear();
                                weekNotesModel.clear();
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
                    Material.background: Material.color(Material.Grey)
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
                    onClicked: stack.replace(registerPage)
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
