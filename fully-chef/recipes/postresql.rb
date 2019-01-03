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

if node['postgresql']['replication']
  archive_path = " /var/lib/pgsql/#{node['postgresql']['version']}/archive/"
  node.default['postgresql']['listen_addresses'] = node['ipaddress']

  execute 'Creating Archive Path' do
    command "mkdir -p #{archive_path} && chmod 700  -R #{archive_path} && chown -R postgres:postgres #{archive_path}"
  end
end

template "/etc/postgresql/#{node['postgresql']['version']}/main/postgresql.conf" do
  source 'postgres/postgresql.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0644'
end

service 'postgresql' do
  action :restart
end
