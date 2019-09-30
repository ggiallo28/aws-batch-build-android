FROM ubuntu:18.04

COPY setup setup

# Grab Java 8 and build tools:
ENV LSB_RELEASE Ubuntu\ 18.04.3\ LTS
ENV USE_CCACHE 1
ENV CCACHE_MAX_SIZE 12G
ENV CCACHE_COMPRESS 1
ENV LANGUAGE C
ENV CCACHE_DIR /ccache

RUN apt-get update && \
apt-get install -y llvm-dev git-core ccache && \
bash ./setup/android_build_env.sh && rm -rf /var/lib/apt/lists/*

RUN apt update && apt -y install python3-pip
RUN pip3 install --upgrade awscli

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
