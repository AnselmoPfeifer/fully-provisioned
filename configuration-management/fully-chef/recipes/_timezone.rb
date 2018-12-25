#
# Cookbook:: devops-challenge
# Recipe:: _timezone
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

template '/etc/timezone' do
  source 'timezone/timezone.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

if node['platform_version'] == '16.04'
  execute 'timedatectl' do
    command "timedatectl set-timezone #{node['tz']}"
  end
else
  execute 'dpkg-reconfigure-tzdata' do
    command '/usr/sbin/dpkg-reconfigure -f noninteractive tzdata'
  end
end