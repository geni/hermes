set :aws_profile,   'geni-prod'
set :keep_releases, 2
set :notify_emails, 'eng@geni.com'

# Generated via: cap aws_dev aws:get_server_list
server '10.21.5.9',  :user => 'hermes', :roles => ['app'],  :nickname => 'hermes-020'
server '10.21.5.15', :user => 'hermes', :roles => ['app'],  :nickname => 'hermes-021'
