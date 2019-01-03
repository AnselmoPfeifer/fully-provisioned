#
# Cookbook:: fully-chef
# Recipe:: deployment
#
# Copyright:: 2018, Anselmo Pfeifer, All Rights Reserved.

remote_file 'Deployment war Package' do
  path "#{node['deployment']['path']}/#{node['deployment']['package']}"
  source "file://#{node['deployment']['folder']}/#{node['deployment']['package']}"
  owner node['deployment']['user']
  group node['deployment']['group']
  mode 0755
end
