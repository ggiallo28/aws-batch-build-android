#!/usr/bin/env bash


DEVICE=$2
MODE=$3
BUCKET=$4

echo "Start with $DEVICE $MODE."
echo "Result in Bucker $BUCKET."

adb kill-server
killall adb
git config --global user.name "AWS"
git config --global user.email "jeff@bezos.money"
git config --global url.https://source.codeaurora.org.insteadOf git://codeaurora.org

# Script to setup an android build environment on Arch Linux and derivative distributions
# Install Repo in the created directory
# Use a real name/email combination, if you intend to submit patches
yes | repo init --depth 1 -u https://github.com/RevengeOS/android_manifest -b r9.0-caf

# Let Repo take care of all the hard work
#
# Tthe x on jx it's the amount of cores you have.
# 4 threads is a good number for most internet connections.
# You may need to adjust this value if you have a particularly slow connection.
yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j2500 --optimized-fetch --prune

# Go to the root of the source tree...
# ...and run the build commands.
. build/envsetup.sh

if [ DEVICE = "potter" ]
  then
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ DEVICE = "x2" ]
  then
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ DEVICE = "hlte" ]
  then
    wget https://gist.githubusercontent.com/Jprimero15/01acbaa4c4070c191b76780a49672e2f/raw/4859e5d1b0a177f499474b9cad763fb9843f0c8b/local_manifest.xml
    mv local_manifest.xml .repo/local_manifest.xml
    yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j2500 --optimized-fetch --prune
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

generate_vendor_hidl_makefiles
make -j$(nproc --all) bacon

tar -zcvf rom.tar.gz $OUT_DIR
aws s3 cp ./rom.tar.gz s3://$BUCKET/$DEVICE/job=$AWS_BATCH_JOB_ID/rom.tar.gz | echo "true"


# scp -r rom.zip chityanj@storage.osdn.net:/storage/groups/r/re/revengeos/rolex
