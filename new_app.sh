#!/bin/bash

if [ -n "$1" ]; then
  docker-compose run --rm api-rails ./new_app.sh $1
  docker-compose run --rm web-react ./new_app.sh $1
  echo "all done!"
else
  echo "Need to set a project name!"
fi
