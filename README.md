# GroundZero

## Requirements

1. docker
2. docker-compose

## Getting Started

Clone this starter project

```
git clone https://github.com/vleango/GroundZero.git [project_name]
```

Initialize the services

```
./new_app.sh [project_name]
```

Launch the project

```
docker-compose up
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
