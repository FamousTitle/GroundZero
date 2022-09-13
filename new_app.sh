#!/bin/bash

if [ -n "$1" ]; then

  export UID=$(id -u)
  export GID=$(id -g)
  
  docker-compose run --rm web-rails ./new_app.sh $1

  echo "all done!"
else
  echo "Need to set a project name!"
fi
