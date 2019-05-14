#!/usr/bin/env bash

adb kill-server
killall adb
git config --global user.name "AWS"
git config --global user.email "jeff@bezos.money"

# Script to setup an android build environment on Arch Linux and derivative distributions
aws s3 cp s3://batch-android-build-ggiallo28/.repo/repo.tar.gz ./repo.tar.gz | echo "true"
tar -zxvf repo.tar.gz | echo "true"
# Install Repo in the created directory
# Use a real name/email combination, if you intend to submit patches
yes | repo init -u https://github.com/RevengeOS/android_manifest -b r9.0-caf

# Let Repo take care of all the hard work
#
# Tthe x on jx it's the amount of cores you have.
# 4 threads is a good number for most internet connections.
# You may need to adjust this value if you have a particularly slow connection.
yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j$(nproc --all) --optimized-fetch --prune
tar -zcvf repo.tar.gz .repo
aws s3 cp ./repo.tar.gz s3://batch-android-build-ggiallo28/.repo/repo.tar.gz | echo "true"

# Go to the root of the source tree...
# ...and run the build commands.
. build/envsetup.sh
lunch revengeos_potter-user
lunch revengeos_potter-user
make -jx bacon

# scp -r rom.zip chityanj@storage.osdn.net:/storage/groups/r/re/revengeos/rolex
