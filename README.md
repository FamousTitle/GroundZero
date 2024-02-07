# GroundZero

## Requirements

1. docker
2. docker-compose

## Getting Started

Clone this starter project

```
git clone git@github.com:FamousTitle/GroundZero.git [project_name]
```

Create local env files

```
cp config/environments/.rails.env config/environments/.rails.local.env
cp config/environments/.nextjs.env config/environments/.nextjs.local.env
cp config/environments/.cms.env config/environments/.cms.local.env
```

Initialize the services

```
./new_app.sh [--rails | --nextjs | --cms] [project_name]
```

Create CMS Database (optional)

```
Log to Adminer (http://localhost:3002/) and create the database (cms-db)
```

Launch the project

```
docker-compose up
```

## To deploy to heroku

```
APP_NAME=app_name
heroku create $APP_NAME
heroku config:set PROJECT_PATH=services/web-rails --app=$APP_NAME
heroku buildpacks:set heroku/ruby --app=$APP_NAME
heroku buildpacks:set https://github.com/vleango/subdir-heroku-buildpack.git --app=$APP_NAME
```

## To rebuild the web-nextjs image

```
IMG_VERSION=20.10.0
REVISION_VERSION=2
TAG=vleango/node:${IMG_VERSION}_${REVISION_VERSION}

docker build \
  --tag $TAG . \
  --file ./config/dockerfiles/Dockerfile-node

docker login
docker push $TAG
```

- make sure to update Dockerfile-node if any version was updated

## To rebuild the web-rails image

```
IMG_VERSION=3.3.0
RAILS_VERSION=7.1.3
REVISION_VERSION=2
TAG=vleango/ruby-rails:${IMG_VERSION}_${RAILS_VERSION}_${REVISION_VERSION}

docker build \
  --tag $TAG . \
  --no-cache \
  --file ./config/dockerfiles/Dockerfile-ruby

docker login
docker push $TAG
```

- make sure to update Dockerfile-ruby if any version was updated

## Other setup

### Rails Credentials

```
docker-compose run --rm api-rails bash

rails db:encryption:init
```

- copy the contents to `credentials:edit`

```
EDITOR=vi rails credentials:edit
```

## Database Setups

### mysql

```
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
  password: rails
  host: db-mysql
```

Sequel Ace / Pro:

```
Name: ground-zero
host: 127.0.0.1
Username: root
Password: rails
Port: 4500
```

### postgres

```
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: db-postgres
  username: rails
  password: rails
```

## Need to access a container?

i.e. the `api-rails` container

```
docker-compose run --rm api-rails bash
```

## Need to use byebug?

To run with `byebug`, you will need to launch all containers in the background, but attach the rails container

```
docker-compose up -d && docker attach famoustitle_api-rails_1
```

## Need to rebuild the containers? Or start from scratch?

Delete all containers

```
docker container ls -aq | xargs docker container rm -f
```

Delete all networks

```
docker network ls -q | xargs docker network rm
```

Delete all volumes

```
docker volume ls -q | xargs docker volume rm
```

Rebuild the containers

```
docker-compose up --build
```
