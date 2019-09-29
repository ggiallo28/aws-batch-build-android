FROM ubuntu:18.10

COPY setup setup

# Grab Java 8 and build tools:
ENV LSB_RELEASE Ubuntu\ 18.04.2\ LTS

RUN apt-get update && \
apt-get install -y git-core ccache && \
bash ./setup/android_build_env.sh && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
