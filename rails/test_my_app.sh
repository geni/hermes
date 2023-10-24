#!/bin/sh

# Usage: time ./test_my_app.sh | tee main.out

# turn on debugging
#set -x

# stop if any command fails
set -e

# Show which tests are being run and their results
export TEST_OPTS=--verbose

bundle config set --local clean 'true'
bundle config set --local path  'vendor/bundle'
bundle install
bundle exec rails test

