#!/bin/sh
# Openshift Interconnect launch script

CONFIG_FILE=${AMQ_HOME}/etc/qdrouterd.conf

${AMQ_HOME}/bin/configure_interconnect.sh ${AMQ_HOME}

exec qdrouterd -c $CONFIG_FILE
