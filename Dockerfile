# Build remco from specific commit
##################################
FROM golang

ENV REMCO_VERSION v0.12.0

# remco (lightweight configuration management tool) https://github.com/HeavyHorst/remco
RUN go get -v github.com/HeavyHorst/remco/cmd/remco
RUN go install github.com/HeavyHorst/remco/cmd/remco@$REMCO_VERSION

# Build base container
######################
FROM ubuntu:bionic
LABEL author="Nathan Snow"
LABEL description="Minecraft Forge server (Minecraft server java edition)"
USER root

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV MC_HOME=/home/minecraft
ENV MINECRAFT_UID=1000
ENV MINECRAFT_GID=1000
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/bin/java
ENV JAVA_MEMORY=512

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    sudo \
    unzip \
    curl \
    wget \
    git \
    gnupg2 \
    openjdk-11-jre-headless

RUN groupadd -g $MINECRAFT_GID minecraft && \
    useradd -s /bin/bash -d /home/minecraft -m -u $MINECRAFT_UID -g minecraft minecraft && \
    passwd -d minecraft && \
    echo "minecraft ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/minecraft

COPY --from=0 /go/bin/remco /usr/local/bin/remco
COPY --chown=minecraft:root remco /etc/remco
RUN chmod -R 0775 etc/remco

USER minecraft
WORKDIR $MC_HOME
VOLUME ["/home/minecraft/server"]

COPY --chown=minecraft:minecraft files/entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

