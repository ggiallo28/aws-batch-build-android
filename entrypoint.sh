#!/usr/bin/env bash
set -x

DEVICE=$1
MODE=$2
BUCKET=$3

echo "Start with $DEVICE $MODE."
echo "Result in Bucker $BUCKET."

cd /
. /setup/android_build_env.sh
rm -rf /ccache
ccache -M $(df -h /ccache --output=size | sed 1d | xargs)

aws s3 ls s3://$BUCKET/$DEVICE/cache.tar.gz
if [[ $? -eq 0 ]]; then
  aws s3 cp s3://$BUCKET/$DEVICE/cache.tar.gz ./cache.tar.gz
  tar -xvzf cache.tar.gz -C /tmp
  mv /tmp/ccache/* /ccache
  rm -rf /tmp/ccache
fi

git config --global user.name "AWS"
git config --global user.email "jeff@bezos.money"
git config --global url.ssh://git@privgit.codeaurora.org.insteadOf ssh://git@git.codeaurora.org
#git config --global url.https://source.codeaurora.org.insteadOf git://codeaurora.org

# Script to setup an android build environment on Arch Linux and derivative distributions
# Install Repo in the created directory
# Use a real name/email combination, if you intend to submit patches
cd /workspace
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

if [ $DEVICE == "potter" ]
  then
    echo "POTTER"
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ $DEVICE == "x2" ]
  then
    echo "X2"
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ $DEVICE == "hlte" ]
  then
    echo "HLTE"
    wget https://gist.githubusercontent.com/Jprimero15/01acbaa4c4070c191b76780a49672e2f/raw/4859e5d1b0a177f499474b9cad763fb9843f0c8b/local_manifest.xml
    mv local_manifest.xml .repo/local_manifest.xml
    yes | repo sync -c -f --force-sync --no-tag --no-clone-bundle -j2500 --optimized-fetch --prune
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

if [ $DEVICE == "tissot" ]
  then
    echo "TISSOT"
    lunch revengeos_$DEVICE-$MODE
    lunch revengeos_$DEVICE-$MODE
fi

. $ANDROID_BUILD_TOP/device/qcom/common/vendor_hal_makefile_generator.sh

make -j$(nproc --all) bacon

rm -rf $DEVICE && mkdir $DEVICE || mkdir $DEVICE
mv /workspace/out/target/product/$DEVICE/*.zip ./$DEVICE
mv /workspace/out/target/product/$DEVICE/*.md5sum ./$DEVICE
tar -cvzf rom.tar.gz ./$DEVICE/
aws s3 cp ./rom.tar.gz s3://$BUCKET/$DEVICE/job=$AWS_BATCH_JOB_ID/rom.tar.gz --acl public-read | echo "true"

tar -cvzf cache.tar.gz /ccache
aws s3 cp ./cache.tar.gz s3://$BUCKET/$DEVICE/cache.tar.gz | echo "true"

ccache -s
# scp -r rom.zip chityanj@storage.osdn.net:/storage/groups/r/re/revengeos/rolex
