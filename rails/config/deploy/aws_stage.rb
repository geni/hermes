set :aws_profile,   'geni-prod'
set :keep_releases, 2
set :notify_emails, 'eng@geni.com'

# Generated via: cap aws_stage aws:generate_server_list
server '10.21.3.36', :user => 'hermes', :roles => ['app'], :nickname => 'stage-010'