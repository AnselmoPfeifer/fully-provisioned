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

if node['postgresql']['is_master_address']
  ip_address = node['postgresql']['master_address']
  archive_path = "/var/lib/postgresql/#{node['postgresql']['version']}/archive"

  execute 'Creating Archive Path' do
    command "mkdir -p #{archive_path} && chmod 700 -R #{archive_path} && chown -R postgres:postgres #{archive_path}"
  end
end


if node['postgresql']['is_slave_address']
  ip_address = node['postgresql']['slave_address']
  data_path = "/var/lib/postgresql/#{node['postgresql']['version']}/data"

  execute 'Creating Archive Path' do
    command "mkdir -p #{data_path} && chmod 700  -R #{data_path} && chown -R postgres:postgres #{data_path}"
  end

  template "#{data_path}/recovery.conf" do
    source 'postgresql/recovery.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
  end
end

if node['postgresql']['replication']
  template "/etc/postgresql/#{node['postgresql']['version']}/main/postgresql.conf" do
    source 'postgresql/postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    variables(listen_addresses: ip_address)
  end

  template "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf" do
    source 'postgresql/pg_hba.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    variables(slave_ip_address: node['postgresql']['slave_address'])
  end
end

service 'postgresql' do
  action :restart
end

service 'postgresql' do
  action :restart
end