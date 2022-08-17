# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("PUMA_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("PUMA_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout ENV.fetch('PUMA_TIMEOUT', 60)
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
#port ENV.fetch("PORT") { 2960 }

bind "tcp://0.0.0.0:#{ENV.fetch('PUMA_PORT', 2960)}/?tcp_nopush=true"

install_base_dir = ENV.fetch('PUMA_BASE_DIR', '/opt/hermes/rails')
if File.exists?(install_base_dir)
  bind "unix://#{install_bas_dir}/run/puma-hermes.sock?umask=0111&backlog=64"
end

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV", "development")

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PUMA_PID_FILE", "tmp/pids/server.pid" )

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
