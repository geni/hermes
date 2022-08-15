# Lifted from: http://unicorn.bogomips.org/examples/unicorn.conf.rb

# should match capistrano deploy_to
capistrano_deploy_to=ENV.fetch('UNICORN_DEPLOY_DIR', '/opt/hermes/rails')

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
default = 1.5 * `grep processor /proc/cpuinfo | wc -l `.to_i
worker_processes (ENV['UNICORN_WORKERS'] || default).to_i

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "#{capistrano_deploy_to}/current" # available in 0.94.0+

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "#{capistrano_deploy_to}/.unicorn-hermes.sock", :backlog => 64
listen (ENV['UNICORN_PORT'] || 8080).to_i, :tcp_nopush => true

# nuke workers after 120 seconds instead of 60 seconds (the default)
timeout (ENV['UNICORN_TIMEOUT'] || 120).to_i

pid "#{capistrano_deploy_to}/run/unicorn.pid"

# some applications/frameworks log to stderr or stdout, so prevent
# them from going to /dev/null when daemonized here:
stderr_path "#{capistrano_deploy_to}/shared/log/unicorn.stderr.log"
stdout_path "#{capistrano_deploy_to}/shared/log/unicorn.stdout.log"

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  ActiveRecord::Base.clear_all_connections!

   # Kill previous instance
   old_pid = "#{server.config[:pid]}.oldbin"
   if File.exists?(old_pid) && server.pid != old_pid
     begin
       Process.kill("QUIT", File.read(old_pid).to_i)
     rescue Errno::ENOENT, Errno::ESRCH
       # someone else did our job for us
     end
   end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
