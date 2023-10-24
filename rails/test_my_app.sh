#!/bin/sh

# Usage: time ./test_my_app.sh

# turn on debugging
#set -x

# stop if any command fails
set -e

bundle config set --local clean 'true'
bundle config set --local path  'vendor/bundle'
bundle install
bundle exec rails test -v

