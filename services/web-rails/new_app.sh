#!/bin/bash

if [ -n "$1" ]; then

  rm -rf ./config log storage tmp node_modules vendor

  rails new $1 -d=postgresql -j=esbuild -c=tailwind --skip-git --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "gem 'famoustitle_rails', git: 'https://github.com/FamousTitle/famoustitle-rails', ref: '31e991892f83ca1c1ce3920da81ecdf8d39f8603'" >> /app/Gemfile
  bundle

  rails g famoustitle_rails:install

  echo "$1 api-rails created!"
else
  echo "Need to set a project name!"
fi