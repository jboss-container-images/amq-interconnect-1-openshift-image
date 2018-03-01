#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Copy launch OpenShift scripts to container
mkdir -p ${JBOSS_HOME}/bin/launch
cp -r ${ADDED_DIR}/* ${JBOSS_HOME}/bin

# Create location and set permissions for configuration files
mkdir -p ${JBOSS_HOME}/conf/
chown -R jboss:root ${JBOSS_HOME}/conf
chmod -R g+rwx ${JBOSS_HOME}/conf

chown -R jboss:root ${JBOSS_HOME}/bin/launch/configure.py
chown -R jboss:root ${JBOSS_HOME}/bin/openshift-launch.sh

chmod -R ug+x ${JBOSS_HOME}/bin/launch/configure.py
chmod -R ug+x ${JBOSS_HOME}/bin/openshift-launch.sh
