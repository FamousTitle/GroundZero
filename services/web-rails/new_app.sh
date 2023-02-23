#!/bin/bash

if [ -n "$1" ]; then

  rm -rf ./app config log storage tmp node_modules vendor

  rails new $1 -d=postgresql -j=esbuild -c=tailwind --skip-git --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "gem 'famoustitle_rails', git: 'https://github.com/FamousTitle/famoustitle-rails', ref: '655c9a617f258da593cd2ca4ae1b38c288e994ed'" >> /app/Gemfile
  bundle

  rails g famoustitle_rails:install

  echo "$1 api-rails created!"
else
  echo "Need to set a project name!"
fi
