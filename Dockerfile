FROM ubuntu:18.04

# Grab Java 8 and build tools:
RUN apt-get update && apt-get -y install adb fastboot bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk openjdk-8-jre wget && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade awscli

# Install Repo, a Google's tool for working with Git in the context of Android.
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > repo
RUN chmod a+x repo && install repo /usr/local/bin && rm -rf repo

## Configuring Ccache (Speedsup Build process)
ENV PATH=~/bin:$PATH
ENV USE_CCACHE=1
ENV USE_PREBUILT_CACHE=1
ENV PREBUILT_CACHE_DIR=/workspace/.ccache
RUN ccache -M 100G

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace

RUN rm -rf /var/lib/apt/lists/*
