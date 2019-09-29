#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
# Uncomment the multilib repo, incase it was commented out
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
echo Installing Dependencies!
# Update
pacman -Syyu
# Install pacaur
pacman -S base-devel git wget multilib-devel cmake svn clang
# Install ncurses5-compat-libs, lib32-ncurses5-compat-libs, aosp-devel, xml2, and lineageos-devel
for package in ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel; do
    git clone https://aur.archlinux.org/"${package}"
    cd "${package}" || continue
    makepkg -si --skippgpcheck
    cd - || break
    rm -rf "${package}"
done

pacman -S android-tools
echo -e "Setting up udev rules for adb!"
curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
chmod 644 /etc/udev/rules.d/51-android.rules
chown root /etc/udev/rules.d/51-android.rules
udevadm control --reload-rules

echo "All Done :'D"
echo "Don't forget to run these commands before building, or make sure the python in your PATH is python2 and not python3"
echo "
virtualenv2 venv
source venv/bin/activate"
