#!/bin/sh

export HOST_PROJECT_FOLDER=$(pwd)

export HOST_USER_ID=$(id -u)
export HOST_USER_GROUP_ID=$(id -g)

export CONTAINER_USER_NAME='user'
export CONTAINER_USER_GROUP_NAME='user'

# build image again
#docker-compose build --no-cache


# bring up the container and run command.sh (defined in docker-compose.yml)
docker-compose up

# enter the container via its shell
#docker-compose exec app bash
