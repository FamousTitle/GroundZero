#!/bin/bash

if [ -n "$1" ]; then

  rm -rf ./app config log storage tmp node_modules vendor

  rails new $1 -d=postgresql -j=esbuild -c=tailwind --skip-git --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "gem 'famoustitle_rails', git: 'https://github.com/FamousTitle/famoustitle-rails', ref: 'e4e36a0e2d935ee85b73cd407099d62dbdb6d46e'" >> /app/Gemfile
  bundle

  rails g famoustitle_rails:install

  rake db:create db:migrate db:seed

  echo "$1 api-rails created!"
else
  echo "Need to set a project name!"
fi
