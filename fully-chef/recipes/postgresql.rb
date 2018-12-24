#
# Cookbook:: fully-chef
# Recipe:: postresql
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

data_directory = node['postgresql']['data_directory']
version = node['postgresql']['version']
initdb_options = node['postgresql']['initdb_options']

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

template "/etc/postgresql/#{node['postgresql']['version']}/main/postgresql.conf" do
  source 'postgresql/postgresql.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  variables(
      listen_addresses: node['postgresql']['listen_addresses']
  )
end

directory data_directory do
  owner 'postgres'
  group 'postgres'
  mode '0700'
  recursive true
  not_if { ::File.exist?("#{data_directory}/PG_VERSION") }
end

bash 'postgresql initdb' do
  user 'postgres'
  code <<-EOC
/usr/lib/postgresql/#{version}/bin/initdb #{initdb_options} -U postgres -D #{data_directory}
  EOC
  not_if { ::File.exist? "#{data_directory}/PG_VERSION" }
end

directory "#{data_directory}/pg_log" do
  owner 'postgres'
  group 'postgres'
  mode '0700'
  recursive true
  not_if { ::File.exist? "#{data_directory}/PG_VERSION" }
end

service 'postgresql' do
  action :restart
end
