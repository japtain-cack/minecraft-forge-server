#!/usr/bin/env bash

export REMCO_HOME=/etc/remco
export REMCO_RESOURCE_DIR=${REMCO_HOME}/resources.d
export REMCO_TEMPLATE_DIR=${REMCO_HOME}/templates
export FORGE_VERSION='1.16.5-36.1.0'

echo "Forge server version set to: $FORGE_VERSION"
echo

sudo chown -R minecraft:minecraft ${MC_HOME}
git config --global --unset core.autocrlf

# Auto updates
if [ -f "${MC_HOME}/server/forge-${FORGE_VERSION}-installer.jar" ]; then
  echo "Existing Forge jar found: forge-${FORGE_VERSION}-installer.jar"
else
  echo -e "\nForge set to latest or no correct forge version found."
  echo -e "Compiling new binarys.\n"
  curl -o forge-instaler.jar https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar && \
    chmod +x *.jar && \
    java -Xmx512M -jar forge-installer.jar --installServer --extract ${MC_HOME}/server
fi

# Launch the specified version
if [ -f ${MC_HOME}/server/forge-${FORGE_VERSION}.jar ]; then
  echo -e "\nStarting Forge..."

  remco

  cd ${MC_HOME}/server && \
    chmod +x *.jar && \
    java -Xms${JAVA_MEMORY}M -Xmx${JAVA_MEMORY}M -XX:+UseG1GC -jar forge-${FORGE_VERSION}.jar nogui
else
  echo "!!! No Forge jar found !!!"
fi

