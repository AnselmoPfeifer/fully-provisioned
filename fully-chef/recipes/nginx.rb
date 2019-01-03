#
# Cookbook:: fully-chef
# Recipe:: nginx
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

package 'nginx' do
  action :install
end

service 'nginx' do
  action :restart
end