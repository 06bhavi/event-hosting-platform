# Baseline configuration for every server in the event platform
class baseline (
  Array[String] $packages   = ['curl', 'htop', 'fail2ban'],
  String        $admin_user = 'clubadmin',
  String        $club_name  = 'Tech Club',
) {

  # 1. Packages
  package { $packages:
    ensure => installed,
  }

  # 2. Admin user with a home directory
  user { $admin_user:
    ensure     => present,
    home       => "/home/${admin_user}",
    managehome => true,
    shell      => '/bin/bash',
    comment    => "${club_name} administrator",
  }

  # 3. SSH hardening: disable root login (drop-in file, safe for ubuntu user)
  file { '/etc/ssh/sshd_config.d/99-baseline.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# Managed by Puppet\nPermitRootLogin no\n",
    notify  => Service['ssh'],
  }

  service { 'ssh':
    ensure => running,
  }

  # 4. fail2ban must be running
  service { 'fail2ban':
    ensure  => running,
    enable  => true,
    require => Package['fail2ban'],
  }

  # 5. Login banner built from facts using a template
  file { '/etc/motd':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('baseline/motd.epp', { 'club_name' => $club_name }),
  }
}
