#!/bin/sh
REGISTRY=$(oc get svc -n default | grep registry |  awk 'FNR == 1 {print $2}'):5000
docker login -p $(oc whoami -t) -u unused -e unused $REGISTRY

BASE_NAME=amq
IMAGE_NAME=interconnect11

docker tag $BASE_NAME/$IMAGE_NAME:latest $REGISTRY/openshift/$IMAGE_NAME:latest
docker push $REGISTRY/openshift/$IMAGE_NAME:latest 
