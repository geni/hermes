# config valid for current version and patch releases of Capistrano
lock "~>3.0"

set :application, "hermes"
set :project, "hermes"
set :repo_url, "https://github.com/geni/hermes.git"

# only deploy rails subdirectory
set :repo_tree, "rails"

# only open 5 concurrent github connections
set :git_max_concurrent_connections, 5

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, Pathname.new('/opt/hermes/rails')

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"
append :linked_dirs, 'log'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }
set :local_user, 'hermes'

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# capistrano-bundler configuration (https://github.com/capistrano/bundler)
append :linked_dirs, '.bundle'
set    :bundle_flags, ''
set    :bundle_without, 'deployment:development:test:vscode'
set    :bundle_config, {
                        'force_ruby_platform' => 'true'
                       }

# capistrano-rbenv configuration (https://github.com/capistrano/rbenv)
set :rbenv_type, :system
set :rbenv_path, '/opt/rbenv'
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_roles, [:app]

def my_env(key, default=nil)
  ENV[key] || ENV[key.upcase] || default
end

def latest_commits(num, caller_args=nil)
  log_args = "-n#{num} --pretty=format:'%h - %d %s <%an>' --abbrev-commit"
  begin
    `git log #{caller_args} #{log_args}`
  rescue Exception => e
    pp e.message, e.backtrace
  end
end

def send_mail(opts)
  to          = fetch(:notify_emails, opts[:to])
  subject     = opts[:subject]
  body        = opts[:body]
  attachments = my_env('attach_files', opts[:attachments])&.split(/[\s,]/)

  cmd  = "echo -e #{body.inspect} | mail"
  cmd += " -s '#{subject}'"
  cmd += " -a #{attachments.join(' -a ')}" if attachments
  cmd += " '#{to}'"

  execute cmd
end

hosts = (my_env('one_server') || my_env('hosts')).to_s.split(',')
if hosts.any?
  set :filter, :hosts => hosts
end

def git_opts
  {
    :in    => :groups,
    :limit => fetch(:git_max_concurrent_connections),
    :wait  => fetch(:git_wait_interval),
  }
end
