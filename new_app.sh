#!/bin/bash

if [ -n "$2" ]; then

  export UID=$(id -u)
  export GID=$(id -g)

  if [ "$1" == "--rails" ]
  then
    docker-compose run --rm web-rails ./new_app.sh $2
  elif [ "$1" == "--nextjs" ]
  then
    docker-compose run --rm web-nextjs ./new_app.sh $2
  else
    echo "none"
  fi
  echo "all done!"
else
  echo "Need to set a project name!"
fi
