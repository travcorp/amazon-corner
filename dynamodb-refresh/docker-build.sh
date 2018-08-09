#!/bin/bash
set -exu

# Build docker image
docker build -t tip-database-refresh ./dynamodb-refresh

echo 'running container'

# Run and pass env variables into docker container
docker run \
    --cap-add SYS_ADMIN \
    -e SOURCE_AWS_KEY \
    -e SOURCE_SECRET_KEY \
    -e SOURCE_REGION \
    -e SOURCE_TABLE_NAME \
    -e DESTINATION_AWS_KEY \
    -e DESTINATION_SECRET_KEY \
    -e DESTINATION_REGION \
    -e DESTINATION_TABLE_NAME \
tip-database-refresh