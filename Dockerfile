FROM ubuntu:18.04

COPY setup setup

# Grab Java 8 and build tools:
ENV LSB_RELEASE Ubuntu\ 18.04.2\ LTS
ENV PATH ~/bin:$PATH
ENV USE_CCACHE 1
ENV USE_PREBUILT_CACHE 1
ENV PREBUILT_CACHE_DIR /workspace/.ccache
#export ccache -M 100G
#+ export ccache -M 100G
#bash: export: `-M': not a valid identifier
#bash: export: `100G': not a valid identifier

RUN apt-get update && \
apt-get install -y git-core ccache && \
bash ./setup/android_build_env.sh && rm -rf /var/lib/apt/lists/*

RUN apt-get -y install python3-pip
RUN pip3 install --upgrade awscli

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
