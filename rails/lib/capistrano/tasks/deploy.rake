puts "Loading deploy tasks..."

namespace :deploy do

  desc 'Restart the rails servers'
  task :restart_web do
    next if my_env('no_restart') || my_env('no_restart_web')

    pid_file = "#{fetch(:deploy_to)}/run/unicorn.pid"

    on roles(:app) do |host|
      if test "[ -e #{pid_file} ]"
        execute :pkill, '-USR2', "--pidfile #{pid_file}"
      end
    end
  end

  after 'deploy:symlink:release', 'deploy:restart_web'

  before :cleanup, :send_deployment_email do
    # don't email unless we've deployed
    on primary(:app) do
      subject = "[Hermes DEPLOYED] #{fetch(:stage)} #{fetch(:branch)}"
      body = ["Deployed at: #{Time.now}", "Deployed by: #{my_env('user')} from #{Socket.gethostname}"]
      body << ''
      body << "ON SERVERS: #{my_env('hosts')}" if my_env('hosts')
      body << "Branch: #{fetch(:branch)}"
      body << 'Last commits:'
      body << ''
      body << latest_commits(10)
      body = body.join("\n")

      info 'Sending email notification...'
      send_mail(:subject => subject, :body => body)
    end
  end

end # namespace :deploy
