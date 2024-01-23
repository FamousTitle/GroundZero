#!/bin/bash

if [ -n "$1" ]; then
  npx create-next-app --use-npm $1 -e https://github.com/FamousTitle/with-next-famoustitle
  mv -n $1/* .
  rm -rf $1
  echo "$1 web-nextjs created!"

  npx prisma migrate dev
  echo "database created!"
  
else
  echo "Need to set a project name!"
fi
