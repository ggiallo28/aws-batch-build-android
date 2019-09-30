FROM ubuntu:18.04

COPY setup setup

# Grab Java 8 and build tools:
ENV USE_CCACHE 1
ENV CCACHE_COMPRESS 1
ENV LANGUAGE C
ENV CCACHE_DIR /ccache

RUN apt-get update && \
apt-get install -y lsb-core lsb-release llvm-dev git-core ccache python3-pip && \
bash ./setup/android_build_env.sh && \
pip3 install --upgrade awscli && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
