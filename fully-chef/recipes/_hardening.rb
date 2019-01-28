#
# Cookbook:: fully-chef
# Recipe:: _hardening
#
# Copyright:: 2019, Anselmo Pfeifer, All Rights Reserved.

# Actions from hardening

# Disable reboot via crtl+alt+del
# https://help.ubuntu.com/lts/serverguide/console-security.html
cookbook_file '/etc/init/control-alt-delete.conf' do
  source 'hardening/control-alt-delete.conf'
  mode 0644
end

# Removing unused shells/logins
ohai 'reload_passwd' do
  action :nothing
  plugin 'etc'
end

node['hardening']['users'].each do |username|
  user username do
    only_if { node['etc']['passwd'].include? username }
    shell '/dev/null'
    notifies :reload, 'ohai[reload_passwd]', :immediately
  end
end

node['hardening']['files_to_remove_permission_suid'].each do | filePath|
  file filePath do
    mode '4750'
  end
end

# Remover permissões SGID
node['hardening']['files_to_remove_permission_sgid'].each do | filePath|
  file filePath do
    mode '0750'
  end
end

cookbook_file '/etc/profile.d/tmout.sh' do
  source 'hardening/tmout.sh'
  mode 0755
end

cookbook_file '/etc/host.conf' do
  source 'hardening/host.conf'
  mode 0644
end

execute 'ssh-keygen -A' do
  not_if { ::File.exists?('/etc/ssh/ssh_host_ed25519_key')}
end

openssh_server node['sshd']['config_file']  do
  Port 22
  PermitRootLogin 'no'
  RSAAuthentication 'yes'
  PubkeyAuthentication 'yes'
  PasswordAuthentication 'no'
  Protocol 2
  HostKey %w{ /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key }
  UsePrivilegeSeparation 'yes'
  KeyRegenerationInterval 3600
  ServerKeyBits 1024
  SyslogFacility 'AUTH'

  LogLevel 'INFO'
  LoginGraceTime 120
  StrictModes 'yes'
  IgnoreRhosts 'yes'
  RhostsRSAAuthentication 'no'
  HostbasedAuthentication 'no'

  PermitEmptyPasswords 'no'
  ChallengeResponseAuthentication 'no'
  X11Forwarding 'yes'
  X11DisplayOffset 10

  PrintMotd 'no'
  PrintLastLog 'yes'
  TCPKeepAlive 'yes'
  AcceptEnv 'LANG LC_*'
  Subsystem 'sftp /usr/lib/openssh/sftp-server'
  UsePAM 'yes'
end

# a) Avoid the SYN attack that causes denial of service.
node.default['sysctl']['params']['net']['ipv4']['tcp_syncookies'] = '1'
node.default['sysctl']['params']['net']['ipv4']['tcp_max_syn_backlog'] = '2048'
node.default['sysctl']['params']['net']['ipv4']['tcp_synack_retries'] = '2'
node.default['sysctl']['params']['net']['ipv4']['tcp_syn_retries'] = '5'

# b) Disable the ping for the machine.
node.default['sysctl']['params']['net']['ipv4']['icmp_echo_ignore_all'] = '0'

# c) Ignore messages sent to broadcast
node.default['sysctl']['params']['net']['ipv4']['icmp_echo_ignore_broadcasts'] = '1'

# d) IP Spoof Protection
node.default['sysctl']['params']['net']['ipv4']['conf']['all']['rp_filter'] = '1'
node.default['sysctl']['params']['net']['ipv4']['conf']['default']['rp_filter'] = '1'

# e) Disabling IP Forward
node.default['sysctl']['params']['net']['ipv4']['ip_forward'] = '1'

# f) Does not accept ICMP redirect
node.default['sysctl']['params']['net']['ipv4']['conf']['all']['send_redirects'] = '1'
node.default['sysctl']['params']['net']['ipv4']['conf']['default']['send_redirects'] = '1'