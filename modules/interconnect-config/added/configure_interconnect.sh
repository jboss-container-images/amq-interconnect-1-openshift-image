#!/bin/bash

HOME_DIR=$1
OUTFILE=$2

function swapVars() {
  sed -i "s/\${HOSTNAME}/$HOSTNAME/g" $1
}

if [[ $QDROUTERD_CONF =~ .*\{.*\}.* ]]; then
    # env var contains inline config
    echo "$QDROUTERD_CONF" > $OUTFILE
elif [[ -n $QDROUTERD_CONF ]]; then
    # treat as path(s)
    IFS=':,' read -r -a array <<< "$QDROUTERD_CONF"
    > $OUTFILE
    for i in "${array[@]}"; do
        if [[ -d $i ]]; then
            # if directory, concatenate to output all .conf files
            # within it
            for f in $i/*.conf; do
                cat "$f" >> $OUTFILE
            done
        elif [[ -f $i ]]; then
            # if file concatenate that to the output
            cat "$i" >> $OUTFILE
        else
            echo "No such file or directory: $i"
        fi
    done
fi

swapVars $OUTFILE

if [ -n "$QDROUTERD_AUTO_MESH_SSL_PROFILE" ]; then
    SSL_PROFILE_CONF="    sslProfile: ${QDROUTERD_AUTO_MESH_SSL_PROFILE}";
fi

if [ "$QDROUTERD_AUTO_MESH_DISCOVERY" = "QUERY" ]; then
    python $HOME_DIR/bin/add_connectors.py $OUTFILE "$SSL_PROFILE_CONF"
elif [ "$QDROUTERD_AUTO_MESH_DISCOVERY" = "INFER" ]; then
    SERVICE_NAME=${QDROUTERD_AUTO_MESH_SERVICE_NAME:-${APPLICATION_NAME}-headless}
    INDEX=$(echo "$HOSTNAME" | rev | cut -f1 -d-)
    PREFIX=$(echo "$HOSTNAME" | rev | cut -f2- -d- | rev)
    COUNT=0
    while [ $COUNT -lt $INDEX ]; do
        cat <<EOF >> $OUTFILE
connector {
    name: ${PREFIX}-${COUNT}
    host: ${PREFIX}-${COUNT}.${SERVICE_NAME}.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local
    port: 55672
    role: inter-router
${SSL_PROFILE_CONF}
    verifyHostname: false
}
EOF
        let COUNT=COUNT+1
    done
fi
