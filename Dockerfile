FROM ubuntu:18.04

# Grab Java 8 and build tools:
RUN bash setup/android_build_env.sh && rm -rf /var/lib/apt/lists/*

COPY setup setup
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
WORKDIR ./workspace
