cmake_minimum_required(VERSION 3.16)

project(KURS VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Шукаємо Qt6. Якщо знайдено, CMake автоматично визначить QT_VERSION_MAJOR, QT_VERSION тощо.
# 💡 ВИПРАВЛЕНО: Повертаємо LinguistTools до find_package, щоб команда qt_create_translation була відомою.
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Sql LinguistTools)

set(TS_FILES KURS_uk_UA.ts)

set(PROJECT_SOURCES
    main.cpp
    Database.cpp
    Database.h
    ${TS_FILES}
)

# 💡 ВИПРАВЛЕННЯ: ЗАЛИШАЄМО ЛИШЕ КОНФІГУРАЦІЮ ДЛЯ QT 6

qt_add_executable(KURS
    MANUAL_FINALIZATION
    ${PROJECT_SOURCES}
    MForm.qml
    build/Desktop_Qt_6_10_0_MinGW_64_bit-Debug/MForm.qml
    Database.cpp main.cpp
    main.cpp
    Database.cpp main.cpp
    Database.cpp main.cpp
)

# qt_create_translation тепер повинен працювати, оскільки LinguistTools знайдено.
qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})

# Використовуємо цілі Qt6::...
set(QT_TARGETS
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Sql
)


# ЛІНКУВАННЯ: Підключаємо всі необхідні бібліотеки
# УВАГА: LinguistTools тут відсутній, оскільки він викликав помилку лінкування.
target_link_libraries(KURS PRIVATE ${QT_TARGETS})


# Налаштування властивостей цілі
# 💡 ВИПРАВЛЕНО: Видаляємо необов'язковий блок для Mac OSX.

set_target_properties(KURS PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS KURS
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Фіналізуємо збірку для Qt 6
qt_finalize_executable(KURS)
