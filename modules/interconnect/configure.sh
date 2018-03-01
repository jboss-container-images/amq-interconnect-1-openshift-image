#!/bin/sh

set -e
SCRIPT_DIR=$(dirname $0)

#chown -R jboss:root ${JBOSS_HOME}
#chmod -R g+rwX ${JBOSS_HOME}

chown -R jboss:root ${SCRIPT_DIR}/configure.py
chmod -R g+rwxX ${SCRIPT_DIR}/configure.py

cp ${SCRIPT_DIR}/configure.py ${JBOSS_HOME}/opt/
python ${JBOSS_HOME}/opt/configure.py
#OUTPUT="$(python ${SCRIPT_DIR}/con.py)"
#echo "${OUTPUT}"
