#!/usr/bin/env bash

# Copyright (C) 2019 ZVNexus
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP build environment on Solus

eopkg it -c system.devel
eopkg it openjdk-8-devel curl-devel git gnupg gperf libgcc-32bit libxslt-devel lzop ncurses-32bit-devel ncurses-devel readline-32bit-devel rsync schedtool sdl1-devel squashfs-tools unzip wxwidgets-devel zip zlib-32bit-devel

# ADB/Fastboot
eopkg bi --ignore-safety https://raw.githubusercontent.com/solus-project/3rd-party/master/programming/tools/android-tools/pspec.xml
eopkg it android-tools*.eopkg;rm android-tools*.eopkg

# udev rules
echo "Setting up udev rules for adb!"
curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
chmod 644 /etc/udev/rules.d/51-android.rules
chown root /etc/udev/rules.d/51-android.rules
usysconf run -f

echo "Installing repo"
curl --create-dirs -L -o /usr/local/bin/repo -O -L https://github.com/akhilnarang/repo/raw/master/repo
chmod a+x /usr/local/bin/repo

echo "You are now ready to build Android!"