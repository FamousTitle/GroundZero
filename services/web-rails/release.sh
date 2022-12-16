#!/bin/bash

# release script for heroku (run after deployment completes)

bundle exec rake db:migrate
