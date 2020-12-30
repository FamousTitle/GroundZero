# GroundZero

## Requirements

1. docker
2. docker-compose

## Getting Started

If this is your first time launching, you will need to have a `.aws.env` file. You can use the sample `.aws.env.sample` file as a reference for the ENV keys required for the application

```
cp config/environments/.aws.env.sample config/environments/.aws.env
```

Launch the project

```
docker-compose up
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
