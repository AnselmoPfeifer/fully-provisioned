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

if node['postgresql']['is_master']
  ip_address = node['postgresql']['master_address']
  replication_address = node['postgresql']['slave_address']
  archive_path = "/var/lib/postgresql/#{node['postgresql']['version']}/archive"

  execute 'Creating Archive Path' do
    command "mkdir -p #{archive_path} && chmod 700 -R #{archive_path} && chown -R postgres:postgres #{archive_path}"
  end
end


if node['postgresql']['is_slave']
  ip_address = node['postgresql']['slave_address']
  replication_address = node['postgresql']['master_address']
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
    variables(
        listen_addresses: ip_address
    )
  end

  template "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf" do
    source 'postgresql/pg_hba.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    variables(
        listen_addresses: ip_address,
        replication_address: replication_address
    )
  end
end

service 'postgresql' do
  action :restart
end

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
