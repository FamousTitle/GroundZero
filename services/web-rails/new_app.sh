#!/bin/bash

if [ -n "$1" ]; then

  rm -rf ./config log storage tmp

  rails new $1 -d=postgresql -c=tailwind --skip-bundle --skip-git --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "gem 'famoustitle_rails', git: 'https://github.com/FamousTitle/famoustitle-rails', ref: '048a32db725a814829885835f9c61d545f40de70'" >> /app/Gemfile
  bundle

  rails g famoustitle_rails:install

  echo "$1 api-rails created!"
else
  echo "Need to set a project name!"
fi