#!/bin/sh
# Loads router image into OpenShift registry
OC_VERSION=$(oc version | grep openshift | grep -o "[0-9]\.[0-9]")
NAMESPACE=$(oc project -q)

BASE_NAME=amq-interconnect
IMAGE_NAME=amq-interconnect-1.2-openshift

oc get svc -n default | grep registry 2>&1 > /dev/null
ret=$?
if [ $ret -eq 1 ]; then
  # Cannot view registry in "default" namespace
  echo "To add view permissions, as system:admin, run:"
  echo ""
  echo "oc policy add-role-to-user view $(oc whoami) -n default"
  echo ""
else
  if [ $(echo "$OC_VERSION>=3.9" | bc -l) -eq 1 ]; then	
    # If OpenShift version is >= 3.9
    REGISTRY=$(oc get svc -n default | grep registry |  awk 'FNR == 1 {print $3}'):5000
  else
    REGISTRY=$(oc get svc -n default | grep registry |  awk 'FNR == 1 {print $2}'):5000
  fi
  
  docker login -p $(oc whoami -t) -u unused $REGISTRY

  docker tag $BASE_NAME/$IMAGE_NAME:latest $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest
  docker push $REGISTRY/$NAMESPACE/$IMAGE_NAME:latest
  ret=$?
  if [ $ret -eq 1 ]; then
    echo "Give user permission to push to OpenShift registry, as system:admin, run:"
    echo ""
    echo "oc policy add-role-to-user system:image-pusher admin $(oc whoami)"
    echo ""
  fi
fi
