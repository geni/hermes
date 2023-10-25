puts "Loading AWS tasks..."

# 2022-10-03:
#   We deploy from VMs and sometimes the time gets way out of sync.
#   When it does we get obscure errors from AWS.
if File.exist?('/usr/bin/chronyc')
  puts "  Syncing time => #{`sudo chronyc makestep >/dev/null && date`}"
end

namespace :aws do

  desc 'get server list'
  task :get_server_list do
    hosts = get_ec2_hosts(%w[app])

    hosts.sort_by!{ |host| host.tags.find{|tag| tag.key == 'Name'}.value }

    # We want the first host for some roles to be primary
    # primary hosts are where ```on primary(...)``` blocks will be executed
    primaries = {
                  :rails  => true,
                  :rake   => true,  # activate crontab on first host
                }

    puts "\n\nReplace the 'server' lines in config/deploy/#{fetch(:stage)}.rb with:\n\n"

    puts "# Generated via: cap #{fetch(:stage)} aws:get_server_list"
    hosts.each do |host|
      name      = host.tags.find {|tag| tag.key == 'Name'}.value
      ip        = host[:private_ip_address]
      role_tag  = host.tags.find{|tag| tag.key == 'geni:capistrano:roles'}
      roles     = role_tag.value.split(/\W+/)
      primary   = roles.any? {|role| primaries.delete(role.to_sym)}

      puts "server '#{ip}', :user => '#{fetch(:local_user)}', :roles => #{roles}, #{":primary => true," if primary} :nickname => '#{name}'"
    end

    puts
  end

end # namespace aws

require 'aws-sdk-ec2'

def get_ec2_hosts(roles, rails_env=fetch(:stage), state='running')

  roles   = [roles].flatten
  client  = Aws::EC2::Client.new
  hosts   = client.describe_instances(:filters => [
              {:name => 'tag:geni:capistrano:roles',  :values => ['*']},
              {:name => 'tag:geni:project',           :values => ["*#{fetch(:project)}*"]},
              {:name => 'tag:geni:RAILS_ENV',         :values => [rails_env]},
              {:name => 'instance-state-name',        :values => [state]},
            ]).reservations.map(&:instances).flatten

  hosts.select! do |host|
    host_roles = host.tags.find {|tag| tag.key == 'geni:capistrano:roles'}.value.split(/[,\s]/)
    (roles & host_roles).any?
  end

  return hosts
end