#!/bin/bash

if [ -n "$1" ]; then

  rm -rf ./services/web-rails/config log storage tmp

docker-compose run --rm web-rails rails new $1 -d=postgresql --skip-bundle --skip-git --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "all done!"
else
  echo "Need to set a project name!"
fi
