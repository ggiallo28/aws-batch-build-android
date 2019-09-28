FROM ubuntu:18.04

# Grab Java 8 and build tools:
RUN apt-get update && \
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

COPY setup setup

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
