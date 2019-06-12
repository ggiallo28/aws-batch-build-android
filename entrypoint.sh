#!/usr/bin/env bash


DEVICE=$1
MODE=$2
BUCKET=$3

echo "Start with $DEVICE $MODE."
echo "Result in Bucker $BUCKET."

git config --global user.name "AWS"
git config --global user.email "jeff@bezos.money"
git config --global url.ssh://git@privgit.codeaurora.org.insteadOf ssh://git@git.codeaurora.org
#git config --global url.https://source.codeaurora.org.insteadOf git://codeaurora.org

# Script to setup an android build environment on Arch Linux and derivative distributions
# Install Repo in the created directory
# Use a real name/email combination, if you intend to submit patches
mkdir -p /bin
mkdir -p /android/lineage
cd /android/lineage
yes | repo init -u https://github.com/LineageOS/android.git -b lineage-16.0

# Let Repo take care of all the hard work
#
# Tthe x on jx it's the amount of cores you have.
# 4 threads is a good number for most internet connections.
# You may need to adjust this value if you have a particularly slow connection.
yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j100 --optimized-fetch --prune

# Go to the root of the source tree...
# ...and run the build commands.
. build/envsetup.sh

if [ DEVICE == "potter" ]
  then
    echo "POTTER"
    breakfast potter
fi

if [ DEVICE == "x2" ]
  then
    echo "X2"
    breakfast x2
fi

mkdir /android/system_dump/
cd /android/system_dump/
wget https://mirrorbits.lineageos.org/full/x2/20190603/lineage-16.0-20190603-nightly-x2-signed.zip
unzip lineage-16.0-20190603-nightly-x2-signed.zip system.transfer.list system.new.dat
git clone https://github.com/xpirt/sdat2img
python sdat2img/sdat2img.py system.transfer.list system.new.dat system.img
mkdir system/
mount system.img system/
./extract-files.sh ~/android/system_dump/
mount /android/system_dump/system
rm -rf /android/system_dump/

croot
brunch x2

tar -zcvf rom.tar.gz $OUT
aws s3 cp ./rom.tar.gz s3://$BUCKET/$DEVICE/job=$AWS_BATCH_JOB_ID/rom.tar.gz | echo "true"


# scp -r rom.zip chityanj@storage.osdn.net:/storage/groups/r/re/revengeos/rolex
