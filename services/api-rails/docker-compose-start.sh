#!/bin/bash

bundle check || bundle install --without production

rm -f /app/tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0
