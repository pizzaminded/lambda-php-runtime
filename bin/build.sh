#!/usr/bin/env bash
docker build -t="php-lambda-runtime" .
CONTAINER_ID=$(docker run -it -d php-lambda-runtime:latest)
echo $CONTAINER_ID

printf "Checking PHP version\n"
docker exec -it $CONTAINER_ID /opt/php/bin/php -v

printf "Extracting PHP from docker image\n"
mkdir -p "runtime"
mkdir -p "runtime/bin"
# Copy whole php directory
docker cp $CONTAINER_ID:/opt/php/bin/php ./runtime/bin/php


printf "Docker cleanups\n"
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID


printf "Building artfifacts\n"
mkdir -p build2
mkdir -p "build2/bin"
#mkdir -p "build2/bin"
cp  ./runtime/bin/php ./build2/bin/php
#rm -rf ./build2/php/php/man
#rm -rf ./build2/php/php-7-bin
#cp ./lambda/bootstrap.php ./build2/bootstrap
chmod +x ./build2/bootstrap
chmod +x ./build2/bin/php

printf "Deployment\n"
cdk deploy --verbose --force

printf "Done\n"

