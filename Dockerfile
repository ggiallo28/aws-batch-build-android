FROM ubuntu:18.04

COPY setup setup

# Grab Java 8 and build tools:
RUN add-apt-repository "deb http://cz.archive.ubuntu.com/ubuntu trusty main"
RUN apt-get update && apt-get install lsb-core
RUN bash ./setup/android_build_env.sh 
RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
