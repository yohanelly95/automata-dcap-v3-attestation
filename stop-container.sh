#!/bin/bash

# Name of the container to stop
CONTAINER_NAME="tee-attestation"

# Check if the container is running
if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "Stopping container: $CONTAINER_NAME"
    docker stop $CONTAINER_NAME

    echo "Deleting container: $CONTAINER_NAME"
    docker rm $CONTAINER_NAME

    echo "Container $CONTAINER_NAME stopped and deleted."
else
    echo "Container $CONTAINER_NAME is not running."
    # Check if the container exists but is stopped
    if [ $(docker ps -a -q -f name=$CONTAINER_NAME) ]; then
        echo "Deleting stopped container: $CONTAINER_NAME"
        docker rm $CONTAINER_NAME
        echo "Container $CONTAINER_NAME deleted."
    fi
fi