#!/usr/bin/env bash

adb kill-server
killall adb
git config --global user.name "AWS"
git config --global user.email "gianluigi@mucciolo.it"

# Script to setup an android build environment on Arch Linux and derivative distributions

# Install Repo in the created directory
# Use a real name/email combination, if you intend to submit patches
yes | repo init -u https://github.com/RevengeOS/android_manifest -b r9.0-caf

# Let Repo take care of all the hard work
#
# Tthe x on jx it's the amount of cores you have.
# 4 threads is a good number for most internet connections.
# You may need to adjust this value if you have a particularly slow connection.
yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j$(nproc --all) --optimized-fetch --prune

# Go to the root of the source tree...
# ...and run the build commands.
. build/envsetup.sh
lunch revengeos_potter-user
lunch revengeos_potter-user
make -jx bacon

# scp -r rom.zip chityanj@storage.osdn.net:/storage/groups/r/re/revengeos/rolex
