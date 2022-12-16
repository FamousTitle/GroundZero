# GroundZero

## Requirements

1. docker
2. docker-compose

## Getting Started

Clone this starter project

```
git clone https://github.com/FamousTitle/GroundZero [project_name]
```

Initialize the services

```
./new_app.sh [project_name]
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

## To rebuild image

```
IMG_VERSION=3.1.2
RAILS_VERSION=7.0.4
APT_FILE=web-rails
NPM_FILE=web-rails
NODE_VERSION=16
TAG=vleango/ruby-rails:${IMG_VERSION}_${RAILS_VERSION}

docker build \
  --tag $TAG . \
  --build-arg IMG_VERSION=${IMG_VERSION} \
  --build-arg RAILS_VERSION=${RAILS_VERSION} \
  --build-arg APT_FILE=${APT_FILE} \
  --build-arg NPM_FILE=${NPM_FILE} \
  --build-arg NODE_VERSION=${NODE_VERSION} \
  --file ./config/dockerfiles/Dockerfile-ruby

docker login
docker push $TAG
```

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
