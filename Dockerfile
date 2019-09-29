FROM ubuntu:18.04

COPY setup setup

# Grab Java 8 and build tools:
RUN apt-get install lsb-release lsb-core 
RUN bash ./setup/android_build_env.sh 
RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
