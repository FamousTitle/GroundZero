#! /bin/bash

docker-compose down

export UID=$(id -u)
export GID=$(id -g)

docker-compose -f docker-compose.yml -f docker-compose.prod.yml run --rm web-nextjs yarn run deploy
