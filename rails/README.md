# Hermes Rails

This is a rails implementation of the hermes server.
I wanted to create a websocket microservice to make
it easier for us to maintain.

## Development Workflows

### Setup development environment

``bundle install --path=vendor/bundle --clean``

### Run the development server

``bundle exec rails server``

### Run the console

``bundle exec rails console``

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

