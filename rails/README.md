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

## Deployment

Deploys are driven by [Capistrano](https://capistranorb.com/) 3.x from your
workstation over SSH. Run every command below from this `rails` directory --
there is no Gemfile at the top of the repo, so `cap` will not even start from
there.

### One-time setup on a new machine

`.bundle` and `vendor/` are both in `.gitignore`, so a fresh clone has no gems
at all. Capistrano is a development-group gem, so you have to install it before
you can deploy:

```sh
cd rails

bundle config set --local clean 'true'
bundle config set --local path 'vendor/bundle'
# For nokogiri gem
bundle config set --local force_ruby_platform 'true'
bundle install

# Should print "Capistrano Version: 3.x.y"
bundle exec cap --version
```

You also need ruby from `.ruby-version` installed under rbenv
(`rbenv install $(cat .ruby-version)`) and an SSH key that can reach the
deploy hosts as the `hermes` user.

If `cap` fails with `rbenv: cap: command not found`, capistrano is missing from
your bundle and the rbenv shim is being reached instead. Two causes:

* You ran bare `cap` instead of `bundle exec cap`. Because gems install under
  `vendor/bundle` there is no `cap` on your `PATH`, so the `bundle exec` prefix
  is required. Run `bundle binstubs capistrano` and use `bin/cap` if you would
  rather not type it.
* Your bundle excludes the `development` group, where `capistrano`,
  `capistrano-rails` and `capistrano-rbenv` are declared. Check with
  `bundle config` and clear it with `bundle config unset --local without`.
  Note that `config/deploy.rb` sets `bundle_without` to skip that group *on the
  server* -- that is correct there, but you need it locally.

### Deploy

```sh
bundle exec cap <stage> deploy
```

Stages live in `config/deploy/` and are pinned to private IPs:

| Stage       | Servers                     | Nicknames                |
| ----------- | --------------------------- | ------------------------ |
| `sandbox`   | `10.21.3.54`                | sandbox                  |
| `aws_dev`   | `10.20.5.12`                | hermes-020               |
| `aws_stage` | `10.21.3.36`                | stage-010                |
| `aws_prod`  | `10.21.5.9`, `10.21.5.15`   | hermes-020, hermes-021   |

All hosts use the `hermes` user and the `app` role. Capistrano will **prompt
for the branch**, defaulting to whatever branch you have checked out locally.
Since `:repo_url` points at `https://github.com/geni/hermes.git`, that branch
has to be pushed to GitHub first -- a local-only branch will fail to deploy.

### Layout on the server

`:deploy_to` is `/opt/hermes/rails`, giving the standard Capistrano tree:

```
/opt/hermes/rails/
|-- releases/<timestamp>/   # the new release
|-- current -> releases/<timestamp>
|-- repo/                   # git mirror of the repo
|-- shared/
|   |-- log/                # linked_dirs
|   `-- .bundle/            # linked_dirs
`-- run/puma.pid            # read by deploy:restart_web
```

`:repo_tree` is `rails`, so `current/` holds the contents of this directory --
`current/config/application.rb`, not `current/rails/config/application.rb`.

After the release is symlinked, `deploy:restart_web` sends `SIGUSR2` to the pid
in `run/puma.pid`, which is a puma phased restart. `deploy:cleanup` keeps the
last 2 releases and emails `eng@geni.com` with the branch and last 10 commits.

### Deploy options

These are read from the environment by `my_env` in `config/deploy.rb`, in
either lower or upper case:

```sh
# Restrict the deploy to a subset of the stage's hosts (comma-separated)
hosts=10.21.5.9 bundle exec cap aws_prod deploy
one_server=10.21.5.9 bundle exec cap aws_prod deploy

# Deploy the code but skip the puma restart
no_restart=1 bundle exec cap aws_prod deploy

# Attach files to the notification email
attach_files=log/capistrano.log bundle exec cap aws_prod deploy
```

### Refresh a stage's server list

Server lines are generated from EC2 tags (`geni:project`, `geni:RAILS_ENV`,
`geni:capistrano:roles`) rather than maintained by hand:

```sh
bundle exec cap <stage> aws:get_server_list
```

Paste the output over the `server` lines in `config/deploy/<stage>.rb`. This
task needs AWS credentials in your environment -- it builds an
`Aws::EC2::Client` with the default credential chain and ignores the
`:aws_profile` set in the stage files.
