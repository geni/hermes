set :keep_releases, 2
set :notify_emails, 'eng@geni.com'

# Generated via: cap aws_dev aws:get_server_list
server '10.20.5.12', :user => 'hermes', :roles => ["app"],  :nickname => 'hermes-020'