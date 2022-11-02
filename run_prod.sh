#! /bin/bash

docker-compose down
# echo "Removing old containers..."
# docker container ls -aq | xargs docker container rm -f && docker volume ls -q | xargs docker volume rm

export UID=$(id -u)
export GID=$(id -g)

echo "Starting new containers..."
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo "Server running!"
