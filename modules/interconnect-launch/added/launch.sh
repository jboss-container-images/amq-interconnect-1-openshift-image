#!/bin/sh
# Openshift Interconnect launch script

CONFIG_FILE=${AMQ_HOME}/etc/qdrouterd.conf

${AMQ_HOME}/bin/configure_interconnect.sh ${AMQ_HOME} $CONFIG_FILE

if [ -f $CONFIG_FILE ]; then
    ARGS="-c $CONFIG_FILE"
fi

exec qdrouterd $ARGS
