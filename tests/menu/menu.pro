QT += core gui quick qml testlib
CONFIG += console testcase c++17 link_pkgconfig
CONFIG -= app_bundle
PKGCONFIG += sdl2
TARGET = menu-tests
SOURCES += test_menu.cpp ../../app/settings/menusettings.cpp
HEADERS += ../../app/settings/menusettings.h
INCLUDEPATH += ../../app/settings
