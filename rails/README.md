# Hermes Rails

This is a rails implementation of the hermes server.
I wanted to create a websocket microservice to make
it easier for us to maintain.

## Development Workflows

### Setup development environment

```sh
bundle config set --local clean 'true'
bundle config set --local path 'vendor/bundle'
# For nokogiri gem
bundle config set --local force_ruby_platform 'true'
bundle install
```

### Run the development server

``bundle exec rails server -b 0.0.0.0``

### Run automated tests

```sh
# Should be 100%
bundle exec rails test:coverage
```

### Test the server

```sh
bundle exec rails server -b 0.0.0.0
# browse to: <host>:3000/test
```

### Update the gems

Here's what I do to update the gems.

```sh
git co -b update_gems

rm Gemfile.lock
bundle install

# should be 100% coverage
bundle exec rails test:coverage

git add -p
git commit -v
git co master
git merge update_gems
git push
git branch -d update_gems
```

### Upgrade rails

Here's what I do to upgrade rails.
First, I update ruby.
Then I update the rails gem in-place.
Then I re-create the app from scratch and copy the source files over.

[Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)

#### Update ruby

```sh
git co -b upgrade_ruby

rbenv install --list
rbenv install {latest}

# update .ruby-version
# remove ruby line from Gemfile
rm Gemfile.lock
bundle install

# Should be 100% coverage
bundle exec rails test:coverage

git add -p
git commit -v
git co master
git merge upgrade_ruby
git push
git branch -d upgrade_ruby
```

#### Update rails gem in-place

```sh
git co -b update_rails

# Update the rails line in Gemfile
rm Gemfile.lock
bundle install

bundle exec rails app:update
# resolve diffs

# Should be 100% coverage
bundle exec rails test:coverage

git add -p
git commit -v
git co master
git merge update_rails
git push
git branch -d update_rails
```

#### Re-create app and copy source over

This ensures that all the rails files we haven't touched are up to date.

```sh
git co -b upgrade_rails

# In the same directory as rails
rails new hermes \
    --skip-git \
    --skip-keeps \
    --skip-mailer \
    --skip-mailbox \
    --skip-action-text\
    --skip-active-record \
    --skip-active-storage \
    --skip-asset-pipeline \
    --skip-javascript \
    --skip-hotwire \
    --skip-jbuilder \
    --skip-bundle \
    --api

mv rails rails.old
mv hermes rails

# git checkout deleted files
# resolve diffs

rm Gemfile.lock
bundle config set --local clean 'true'
bundle config set --local path 'vendor/bundle'
bundle install

# Should be 100% coverage
bundle exec rails test:coverage

git add -p
git commit -v
git co master
git merge upgrade_rails
git push
git branch -d upgrade_rails
```
