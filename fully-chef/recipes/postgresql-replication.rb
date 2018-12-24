#
# Cookbook:: fully-chef
# Recipe:: replication-postresql
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

include_recipe 'hosts_file'

data_directory = node['postgresql']['data_directory']

execute 'usermod -aG sudo postgres'

directory '/var/lib/postgresql/.ssh' do
  owner 'postgres'
  group 'postgres'
  mode '0755'
  action :create
end

cookbook_file '/var/lib/postgresql/.ssh/config' do
  source 'postgresql/config'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  action :create
end

cookbook_file '/var/lib/postgresql/.ssh/id_rsa.pub' do
  source 'postgresql/id_rsa.pub'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  action :create
end

cookbook_file '/var/lib/postgresql/.ssh/authorized_keys' do
  source 'postgresql/authorized_keys'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  action :create
end

if node['postgresql']['is_master']
  ip_address = node['postgresql']['master_address']
  replication_address = node['postgresql']['slave_address']

  cookbook_file '/var/lib/postgresql/.ssh/id_rsa' do
    source 'postgresql/id_rsa'
    owner 'postgres'
    group 'postgres'
    mode '0400'
    action :create
  end
end

if node['postgresql']['is_slave']
  ip_address = node['postgresql']['slave_address']
  replication_address = node['postgresql']['master_address']

  template "#{data_directory}recovery.conf" do
    source 'postgresql/recovery.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    variables(
        data_directory: node['postgresql']['data_directory'],
        master_domain: node['postgresql']['master_domain'],
        replication_username: node['postgresql']['replication_username'],
        replication_password: node['postgresql']['replication_password']
    )
  end

  node.default['postgresql']['pg_hba'] = [
      {
          :type => 'host',
          :db => 'all',
          :user => node['postgresql']['replication_username'],
          :addr => "#{node['postgresql']['slave_address']}",
          :method => 'md5'
      },

      {
          :type => 'host',
          :db => 'all',
          :user => node['postgresql']['replication_username'],
          :addr => "#{node['postgresql']['master_address']}",
          :method => 'md5'
      }
  ]
end

hosts_file_entry node['postgresql']['master_address'] do
  hostname node['postgresql']['master_domain']
  comment "Override by chef"
end

hosts_file_entry node['postgresql']['slave_address'] do
  hostname node['postgresql']['slave_domain']
  comment "Override by chef"
end

node.default['postgresql']['pg_hba'] = [
    {
        :type => 'host',
        :db => 'replication',
        :user => node['postgresql']['replication_username'],
        :addr => node['postgresql']['slave_address'],
        :method => 'md5'
    },

    {
        :type => 'host',
        :db => 'replication',
        :user => node['postgresql']['replication_username'],
        :addr => "#{node['postgresql']['master_address']}",
        :method => 'md5'
    }
]

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

service 'postgresql' do
  action :restart
end
