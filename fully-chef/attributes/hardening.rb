default['hardening']['users'] = %w(
  daemon
  bin
  sys
  games
  man
  lp
  mail
  news
  uucp
  proxy
  www-data
  backup
  list irc
  gnats
  nobody
  libuuid
  syslog
  messagebus
  landscape
  sshd
  pollinate
  zabbix
)

default['hardening']['files_to_remove_permission_sgid'] = %w(
  /usr/bin/newgrp
  /usr/bin/gpasswd
  /usr/bin/fping
  /usr/bin/fping6
  /bin/ping
  /bin/mount
  /bin/umount
  /bin/ping6
  /sbin/mount.nfs
  /usr/bin/chfn
  /usr/bin/chsh
  /usr/bin/bsd-write
  /usr/bin/wall
  /usr/bin/expiry
  /usr/bin/chage
)

# Lista de arquivos para remover as permissoes de execusao para os Usuarios
default['hardening']['files_to_remove_permission_suid'] = %w(
  /usr/bin/passwd
  /bin/su
)