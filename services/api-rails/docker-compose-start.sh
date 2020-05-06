#!/bin/bash

bundle check || bundle install --without production

bundle exec rake db:setup && rm -f /app/tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0
