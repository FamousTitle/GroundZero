#!/bin/bash

if [ -n "$1" ]; then
  rails new $1 -d=mysql --skip-bundle --skip-git --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-action-cable --skip-turbolinks --skip-test --skip-system-test --skip-javascript --force
  mv -n $1/* .
  rm -rf $1

  echo "gem 'famoustitle_rails', git: 'https://github.com/vleango/famoustitle-rails', tag: '1.3.0'" >> /app/Gemfile
  bundle

  rails g famoustitle_rails:install

  echo "$1 api-rails created!"
else
  echo "Need to set a project name!"
fi
