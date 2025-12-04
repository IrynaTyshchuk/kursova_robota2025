cmake_minimum_required(VERSION 3.16)

project(diary VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Sql Quick QuickControls2 Widgets)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appdiary
    main.cpp
)

target_compile_features(appdiary PRIVATE cxx_std_17)

target_sources(appdiary
    PRIVATE
        Database.h
        Database.cpp


)

qt_add_qml_module(appdiary
    URI diary
    VERSION 1.0
    QML_FILES
        Main.qml
    RESOURCES resurs.qrc
)

set_target_properties(appdiary PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appdiary
    PRIVATE
        Qt6::Quick
        Qt6::Sql
        Qt6::QuickControls2
        Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appdiary
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
