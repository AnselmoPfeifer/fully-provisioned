#
# Cookbook:: fully-chef
# Recipe:: nginx
#
# Copyright:: 2019, Anselmo Pfeifer, All Rights Reserved.

blacklisted = "#{node['nginx']['default_directory']}/blacklisted"

user 'www-data' do
  home node['nginx']['default_directory']
  shell '/bin/bash'
  manage_home true
  system true
  action :create
end

file '/etc/sudoers.d/www-data' do
  mode 0600
  content <<-EOF
www-data ALL=(ALL) NOPASSWD:ALL
  EOF
  owner 'root'
  group 'root'
end

include_recipe 'fully-chef::php-fpm'

package 'nginx' do
  action :install
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

cookbook_file '/etc/nginx/blockips.conf' do
  source 'nginx/blockips.conf'
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

cookbook_file "#{blacklisted}/index.php" do
  source 'nginx/blacklisted.php'
  mode 0644
end

def enable_sites(file_name)
  link "/etc/nginx/sites-enabled/#{file_name}" do
    to "/etc/nginx/sites-available/#{file_name}"
  end
end

link "#{blacklisted}/blockips.txt" do
  to '/etc/nginx/blockips.conf'
  group 'www-data'
  owner 'www-data'
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

enable_sites 'default'

service 'nginx' do
  service_name 'nginx'
  supports start: true, stop: true, restart: true, reload: true
  action [:enable, :start]
end

