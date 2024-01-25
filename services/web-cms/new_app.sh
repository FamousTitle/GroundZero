#!/bin/bash

if [ -n "$1" ]; then
  npx create-strapi-app@latest $1
  rm -rf $1/src/api
  mv ./templates/* $1/src/.
  rm -rf ./templates
  mv -n $1/* .
  rm -rf $1

  echo "$1 web-cms created!"
else
  echo "Need to set a project name!"
fi
