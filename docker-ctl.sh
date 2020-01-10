#!/bin/bash
#
#
# Docker image build run helper
# Maintainer: David Ryder
#
CMD_LIST=${@:-"help"} # build | build-push | run | bash | stop
DOCKER_TAG_NAME="nginxproxy1"

# What docker install to use: Mac OS X or Ubuntu
DOCKER_CMD=`which docker`
DOCKER_CMD=${DOCKER_CMD:-"/snap/bin/microk8s.docker"}
echo "Using: "$DOCKER_CMD
if [ -d $DOCKER_CMD ]; then
    echo "Docker is missing: "$DOCKER_CMD
    exit 1
fi

$DOCKER_CMD system prune -f

_getDockerContainerId() {
  IMAGE_NAME=${1:-"Image Name Missing"}
  DOCKER_ID=`docker container ps --format '{{json .}}' \
    | jq --arg SEARCH_STR "$IMAGE_NAME" \
    -r '[. | select(.Image | test($SEARCH_STR) ) \
    | {ID, Names, Image } ][0]' \
    | jq -r .ID`
    echo $DOCKER_ID
}

_runCommand() {
  CMD=${1:-"help"}
  echo "Running [$CMD]"
  if [ $CMD == "build" ]; then
    echo "Building local: "$DOCKER_TAG_NAME
    $DOCKER_CMD build -t $DOCKER_TAG_NAME .

  elif [ $CMD == "run" ]; then
    echo "Docker running $DOCKER_TAG_NAME"
    $DOCKER_CMD run --rm --detach                   \
              -p $NGINX_HTTP_PORT:$NGINX_HTTP_PORT -p $NGINX_HTTPS_PORT:$NGINX_HTTPS_PORT    \
              -it                \
              $DOCKER_TAG_NAME
    $DOCKER_CMD ps

  elif [ $CMD == "bash" ]; then
    docker exec -it $(_getDockerContainerId ${DOCKER_TAG_NAME}) /bin/bash

  elif [ $CMD == "stop" ]; then
    docker stop $(_getDockerContainerId ${DOCKER_TAG_NAME})

  else
    echo "Commands: build | build-push | run | bash | stop "
    exit 1
  fi
}

for CMD in $CMD_LIST
do
  _runCommand $CMD
done
