#!/usr/bin/env bash
set -x

DEVICE=$1
MODE=$2
BUCKET=$3

echo "Start with $DEVICE $MODE."
echo "Result in Bucker $BUCKET."


# Grab Java 8 and build tools:
apt-get update && \
apt-get -y install openjdk-8-jdk openjdk-8-jre git-core gnupg flex bison \
gperf build-essential zip unzip xsltproc zlib1g-dev g++-multilib gawk \
libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev curl g++\
lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc zip zlib1g-dev \
adb autoconf automake axel bc clang cmake expat fastboot gcc gcc-multilib \
htop imagemagick lib32z1-dev libtinfo5 libcap-dev libexpat1-dev \
libgmp-dev liblz4-* liblzma* libmpc-dev libmpfr-dev libncurses5-dev \
libsdl1.2-dev libssl-dev libtool lzma* lzop maven python3-setuptools \
ncftp ncurses-dev patch patchelf pkg-config pngcrush pngquant python \
python-all-dev re2c schedtool squashfs-tools subversion texinfo w3m \
--no-install-recommends python3-pip && rm -rf /var/lib/apt/lists/*
pip3 install --upgrade awscli

. /setup/setup.sh
. /setup/ccache.sh
. /setup/ninja.sh

# Install Repo, a Google's tool for working with Git in the context of Android.
curl https://storage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo && install repo /usr/local/bin && rm -rf repo

## Configuring Ccache (Speedsup Build process)
export PATH=~/bin:$PATH
export USE_CCACHE=1
export USE_PREBUILT_CACHE=1
export PREBUILT_CACHE_DIR=/workspace/.ccache
export ccache -M 100G

#adb kill-server
#killall adb
git config --global user.name "AWS"
git config --global user.email "jeff@bezos.money"
git config --global url.ssh://git@privgit.codeaurora.org.insteadOf ssh://git@git.codeaurora.org
#git config --global url.https://source.codeaurora.org.insteadOf git://codeaurora.org

# Script to setup an android build environment on Arch Linux and derivative distributions
# Install Repo in the created directory
# Use a real name/email combination, if you intend to submit patches
yes | repo init --depth 1 -u https://github.com/RevengeOS/android_manifest -b r9.0-caf

# Let Repo take care of all the hard work
#
# Tthe x on jx it's the amount of cores you have.
# 4 threads is a good number for most internet connections.
# You may need to adjust this value if you have a particularly slow connection.
yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j100 --optimized-fetch --prune

# Go to the root of the source tree...
# ...and run the build commands.
echo "run envsetup.sh"
. /workspace/build/envsetup.sh

if [ DEVICE == "potter" ]
  then
    echo "POTTER"
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ DEVICE == "x2" ]
  then
    echo "X2"
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ DEVICE == "hlte" ]
  then
    echo "HLTE"
    wget https://gist.githubusercontent.com/Jprimero15/01acbaa4c4070c191b76780a49672e2f/raw/4859e5d1b0a177f499474b9cad763fb9843f0c8b/local_manifest.xml
    mv local_manifest.xml .repo/local_manifest.xml
    yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j2500 --optimized-fetch --prune
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ DEVICE == "tissot" ]
  then
    echo "TISSOT"
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

. $ANDROID_BUILD_TOP/device/qcom/common/vendor_hal_makefile_generator.sh

make -j$(nproc --all) bacon

tar -zcvf rom.tar.gz $OUT_DIR
aws s3 cp ./rom.tar.gz s3://$BUCKET/$DEVICE/job=$AWS_BATCH_JOB_ID/rom.tar.gz | echo "true"


# scp -r rom.zip chityanj@storage.osdn.net:/storage/groups/r/re/revengeos/rolex
