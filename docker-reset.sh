#! /bin/bash

# docker reset
docker container ls -aq | xargs docker container rm -f && docker volume ls -q | xargs docker volume rm && docker network ls -q | xargs docker network rm

# clean db
docker-compose run --rm web-rails rake db:clean

echo "Docker resetted and DB cleaned!"
