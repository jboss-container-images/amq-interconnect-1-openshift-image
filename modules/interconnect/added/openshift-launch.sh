#!/bin/sh
# Openshift Interconnect launch script

CONFIG_FILE=$JBOSS_HOME/conf/qdrouterd.conf

python ${JBOSS_HOME}/bin/launch/configure.py $CONFIG_FILE
exec qdrouterd -c $CONFIG_FILE
