set :aws_profile,   'geni-prod'
set :keep_releases, 2
set :notify_emails, 'eng@geni.com'

puts "\nRetrieving EC2 host list..."

hosts = get_ec2_hosts(:app)
hosts.sort_by!{ |host| host.tags.find{|tag| tag.key == 'Name'}.value }
hosts.each do |host|
  name  = host.tags.find {|tag| tag.key == 'Name'}.value
  ip    = host[:private_ip_address]
  roles = host.tags.find{|tag| tag.key == 'geni:capistrano:roles'}.value.split(/\W+/)

  puts "  Adding: #{name.ljust(20)}#{ip.rjust(13)}, roles: #{roles}"
  server ip, :user => fetch(:local_user), :roles => roles
end
puts "\n"
