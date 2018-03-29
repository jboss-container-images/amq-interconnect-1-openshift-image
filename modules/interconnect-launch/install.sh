#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Copy launch OpenShift scripts to container
mkdir -p ${AMQ_HOME}/bin
cp -r ${ADDED_DIR}/* ${AMQ_HOME}/bin

chown -R jboss:root ${AMQ_HOME}/bin
chmod -R ug+rx ${AMQ_HOME}/bin
