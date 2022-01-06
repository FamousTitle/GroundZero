#!/bin/bash

if [ -n "$1" ]; then
  rails new $1 -d=postgresql --skip-bundle --skip-git --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-action-cable --skip-asset-pipeline --skip-javascript --skip-hotwire --skip-jbuilder --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "gem 'famoustitle_rails', git: 'https://github.com/vleango/famoustitle-rails', ref: '4a237a3'" >> /app/Gemfile
  bundle

  rails g famoustitle_rails:install

  echo "$1 api-rails created!"
else
  echo "Need to set a project name!"
fi
