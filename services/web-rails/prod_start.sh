#!/bin/bash

bundle check || bundle install

rake assets:clobber
rake assets:precompile

rake db:migrate

rm -f /app/tmp/pids/server.pid && RAILS_ENV=production rails s
