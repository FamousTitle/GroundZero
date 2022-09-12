#!/bin/bash

if [ -n "$1" ]; then

  rm -rf ./config log storage tmp

  rails new $1 -d=postgresql --skip-bundle --skip-git --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-action-cable --skip-asset-pipeline --skip-javascript --skip-hotwire --skip-jbuilder --skip-test --skip-system-test --force
  mv -n $1/* .
  rm -rf $1

  echo "$1 api-rails created!"
else
  echo "Need to set a project name!"
fi
