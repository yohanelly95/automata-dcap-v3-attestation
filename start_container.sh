#!/bin/bash

# Name of the image and container
IMAGE_NAME="tee-attestation"
CONTAINER_NAME="tee-attestation"

# Check if the container already exists
if [ $(docker ps -a -q -f name=$CONTAINER_NAME) ]; then
    echo "Starting existing container: $CONTAINER_NAME"
    docker start $CONTAINER_NAME
else
    echo "Creating and starting new container: $CONTAINER_NAME"
    docker run -d --name $CONTAINER_NAME $IMAGE_NAME
fi

echo "Container $CONTAINER_NAME is now running."
