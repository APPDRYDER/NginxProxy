FROM ubuntu:18.04

# Update OS and packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    vim \
    iputils-ping \
    curl \
    nginx

# Extras
# net-tools nmap \
# mariadb-client openjdk-8-jdk

# Software Components Required

# Directories
WORKDIR /root
ENV ROOT_DIR=/root
ENV SW_DIR=/root

# Add software components
#RUN mkdir -p $SW_DIR
#COPY reverse-proxy.conf     $SW_DIR
COPY configure-nginx.sh     $SW_DIR
COPY envvars.sh             $SW_DIR

# Install ....

# Cleanup

# Start up
#CMD $SW_DIR/startup.sh
CMD $SW_DIR/configure-nginx.sh
