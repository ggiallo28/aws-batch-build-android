FROM arm64v8/ubuntu

# Grab Java 8 and build tools:

RUN apt-get -y update
RUN apt-get -y install gcc-snapshot
RUN apt-get -y install gcc-6 g++-6

RUN apt-get -y install openjdk-8-jdk openjdk-8-jre git-core gnupg flex bison gperf build-essential zip unzip xsltproc zlib1g-dev

RUN apt-get -y install gawk curl python python3-pip lzop maven python3-setuptools ncftp ncurses-dev patch patchelf pkg-config pngcrush pngquant  python-all-dev re2c schedtool squashfs-tools subversion texinfo w3m

RUN apt-get -y install xsltproc zip zlib1g-dev autoconf automake axel bc clang cmake expat htop imagemagick libtinfo5 libcap-dev libexpat1-dev libgmp-dev liblz4-* liblzma* libmpc-dev libmpfr-dev libncurses5-dev libsdl1.2-dev libssl-dev libtool xz-utils  --no-install-recommends

RUN apt-get -y install x11proto-core-dev libx11-dev ccache libgl1-mesa-dev libxml2-utils gcc

RUN apt-get -y install android-tools-fastboot android-tools-adb

RUN apt-get install zlib1g

RUN rm -rf /var/lib/apt/lists/*
RUN pip3 install --upgrade awscli

COPY setup setup
RUN bash ./setup/setup.sh
RUN bash ./setup/ccache.sh
RUN bash ./setup/ninja.sh

# Install Repo, a Google's tool for working with Git in the context of Android.
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > repo
RUN chmod a+x repo && install repo /usr/local/bin && rm -rf repo

## Configuring Ccache (Speedsup Build process)
ENV PATH=~/bin:$PATH
ENV USE_CCACHE=1
ENV USE_PREBUILT_CACHE=1
ENV PREBUILT_CACHE_DIR=~/.ccache
RUN ccache -M 100G

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
ENTRYPOINT ["./../entrypoint.sh"]

RUN rm -rf /var/lib/apt/lists/*
