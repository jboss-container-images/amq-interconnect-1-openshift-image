#!/bin/sh
set -e

INSTANCE_DIR=$1
CONFIGMAP=${AMQ_HOME}/etc/configmap

DISABLER_TAG="<!-- Remove this tag to enable custom configuration -->"

declare -a CONFIG_FILES=("QDROUTERD_CONF")

function swapVars() { 
  sed -i "s/\${HOSTNAME}/$HOSTNAME/g" $1
}

for config_file in ${CONFIG_FILES[@]};
do
  
  file_text="${!config_file}"
  file_text=$(echo "$file_text" | sed  "/^$/d") # Remove empty lines

  # Format env var into filename 
  fname=$(echo "$config_file" | tr '[:upper:]' '[:lower:]' | sed -e 's/_/./g')

  #If file_text has disabler tag or is an empty/whitspace string 
  if echo "$file_text" | grep -q "$DISABLER_TAG" || [[ -z "${file_text// }" ]]; then  
     
    echo "Custom Configuration file '$config_file' is disabled"

  else
   
    echo "Custom Configuration file '$config_file' is enabled"
    
    if mount | grep $CONFIGMAP > /dev/null; then
      echo "ConfigMap volume mounted, copying over configuration files ..."
      cp  $CONFIGMAP/$fname $INSTANCE_DIR/etc/$fname
    else
      echo "ConfigMap volume not mounted.."
      # Overwrite default configuration file
      echo "$file_text" > $INSTANCE_DIR/etc/$fname
    fi
 
  fi

  # Swap env vars into configuration file
  swapVars $INSTANCE_DIR/etc/$fname

done
