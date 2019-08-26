#!/bin/sh

export HOST_PROJECT_FOLDER=$(pwd)

export HOST_USER_ID=$(id -u)
export HOST_USER_GROUP_ID=$(id -g)

export CONTAINER_USER_NAME='user'
export CONTAINER_USER_GROUP_NAME='user'

docker-compose up
