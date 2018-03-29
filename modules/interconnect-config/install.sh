#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Create location and set permissions for configuration files
mkdir -p ${AMQ_HOME}/etc/configmap
chown -R jboss:root ${AMQ_HOME}/etc
chmod -R ug+rwx ${AMQ_HOME}/etc

# Copy launch OpenShift scripts to container
mkdir -p ${AMQ_HOME}/bin
cp -r ${ADDED_DIR}/* ${AMQ_HOME}/bin

chown -R jboss:root ${AMQ_HOME}/bin
chmod -R ug+rx ${AMQ_HOME}/bin
