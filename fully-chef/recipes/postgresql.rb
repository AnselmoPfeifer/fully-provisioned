#
# Cookbook:: fully-chef
# Recipe:: postresql
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

apt_repository node['postgresql']['apt_repository'] do
  uri node['postgresql']['apt_uri']
  distribution "#{node['postgresql']['apt_distribution']}-pgdg"
  components node['postgresql']['apt_components']
  key node['postgresql']['apt_key']
  keyserver node['postgresql']['apt_keyserver']
end

node['postgresql']['libs'].each do | lib |
  package lib do
    options "-t #{node['postgresql']['apt_distribution']}-pgdg"
  end
end

package "postgresql-#{node['postgresql']['version']}"
package "postgresql-contrib-#{node['postgresql']['version']}"
package "postgresql-#{node['postgresql']['version']}-dbg"

template '/tmp/set_password.sh' do
  source 'postgresql/set_password.sh.erb'
  mode '0744'
  variables(
      default_username: node['postgresql']['default_username'],
      default_password: node['postgresql']['default_password'],
      replication_username: node['postgresql']['replication_username'],
      replication_password: node['postgresql']['replication_password']
  )
end

execute 'force_reset_password' do
  command 'date > /dev/null'
  action :nothing
end

execute 'set_password_postgres' do
  command 'sh /tmp/set_password.sh'
  subscribes :run, 'execute[force_reset_password]', :immediately
  notifies :restart, 'service[postgresql]'
end

service 'postgresql' do
  action :restart
end
