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

### Upgrade rails

Here's what I do to upgrade rails.
First, I update ruby.
Then I update the rails gem in-place.
Then I re-create the app from scratch and copy the source files over.

[Instrutions](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)

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
