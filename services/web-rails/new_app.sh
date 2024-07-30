#!/bin/bash

if [ -n "$1" ]; then

  rm -rf ./app config log storage tmp node_modules vendor

  rails new $1 -d=postgresql -j=esbuild -c=tailwind --skip-git --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "gem 'famoustitle_rails', git: 'git@github.com:FamousTitle/famoustitle-rails.git', group: :development" >> /app/Gemfile
  bundle

  rails g famoustitle_rails:install

  bundle exec rake db:clean

  echo "$1 api-web created!"
else
  echo "Need to set a project name!"
fi
