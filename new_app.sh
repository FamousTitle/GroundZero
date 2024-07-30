#!/bin/bash

if [ -n "$2" ]; then

  export UID=$(id -u)
  export GID=$(id -g)

  if [ "$1" == "--rails" ]
  then
    echo "Removing old docker containers and resources..."
    docker container ls -aq | xargs docker container rm -f && docker volume ls -q | xargs docker volume rm && docker network ls -q | xargs docker network rm
    echo "done!"

    echo "copy .rails.env to .rails.local.env"
    cp config/environments/.rails.env config/environments/.rails.local.env

    docker-compose run --rm web-rails ./new_app.sh $2

    echo "touch /app/javascript/controllers/local_controllers/index.js"
    mkdir -p services/web-rails/app/javascript/controllers/local_controllers
    touch services/web-rails/app/javascript/controllers/local_controllers/index.js


  elif [ "$1" == "--nextjs" ]
  then
    docker-compose run --rm web-nextjs ./new_app.sh $2
  elif [ "$1" == "--cms" ]
  then
    docker-compose run --rm web-cms ./new_app.sh $2
  else
    echo "none"
  fi
  echo "all done!"
else
  echo "Need to set a project name!"
fi
