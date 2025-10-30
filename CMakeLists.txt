cmake_minimum_required(VERSION 3.16)

project(KURS VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Sql LinguistTools)

set(TS_FILES KURS_uk_UA.ts)

set(PROJECT_SOURCES
    main.cpp
    Database.cpp
    Database.h
    ${TS_FILES}
)

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

qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})

set(QT_TARGETS
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Sql
)

target_link_libraries(KURS PRIVATE ${QT_TARGETS})

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

qt_finalize_executable(KURS)
