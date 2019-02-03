#
# Cookbook:: fully-chef
# Recipe:: nginx
#
# Copyright:: 2019, Anselmo Pfeifer, All Rights Reserved.

blacklisted = "#{node['nginx']['default_directory']}/blacklisted"

include_recipe 'fully-chef::php-fpm'

package 'nginx' do
  action :install
end

user 'www-data' do
  home node['nginx']['default_directory']
  shell '/bin/bash'
  manage_home true
  action :nothing
end

sudo 'www-data' do
  user 'www-data'
end

directory node['nginx']['default_directory'] do
  owner 'www-data'
  group 'www-data'
  recursive true
  mode 0755
end

directory blacklisted do
  group 'www-data'
  owner 'www-data'
  mode '0755'
  action :create
end

def enable_sites(file_name)
  link "/etc/nginx/sites-enabled/#{file_name}" do
    to "/etc/nginx/sites-available/#{file_name}"
  end
end

template '/etc/nginx/sites-available/default' do
  source 'nginx/default.conf.erb'
  variables({
    :ip_address => node['nginx']['ip_address'],
    :default_directory => node['nginx']['default_directory'],
    :domains => node['nginx']['domains'],
    :log_dir => node['nginx']['log_dir']
   })
end

cookbook_file "#{node['nginx']['default_directory']}/info.php" do
  source 'nginx/info.php'
  mode 0644
  group 'www-data'
  owner 'www-data'
end

cookbook_file "#{node['nginx']['default_directory']}/index.php" do
  source 'nginx/index.php'
  mode 0644
  group 'www-data'
  owner 'www-data'
end

file '/etc/nginx/blockips.conf' do
  mode 0644
  group 'www-data'
  owner 'www-data'
  action :nothing
end

cookbook_file "#{blacklisted}/index.php" do
  source 'nginx/blacklisted.php'
  mode 0644
  group 'www-data'
  owner 'www-data'
end

link '/etc/nginx/blockips.conf' do
  to "#{blacklisted}/blockips.txt"
  link_type :symbolic
  group 'www-data'
  owner 'www-data'
  action :create
  not_if { ::File.exist?("#{blacklisted}/blockips.txt") }
end

service 'nginx' do
  service_name 'nginx'
  supports start: true, stop: true, restart: true, reload: true
  action [:enable, :start]
end

