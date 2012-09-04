# Class: bind::setup
#
# This class installs bind for CentOS / RHEL
#
define bind::setup (
  $ensure    = installed,
  $bindSetup = {},
  $boot      = true,
  $status    = 'running',
  $rdncGen   = true,
  $firewall  = false,
  $port      = 53
) {

  include conf

  $conf_bind_override = $bindSetup
  $conf_bind_default = $conf::default
  $conf_setup = $conf::setup

  package { bind:
    ensure => $ensure,
  }

  $packages = ['bind-libs', 'bind-utils']

  package { $packages:
    ensure  => $ensure,
    require => Package['bind']
  }

  exec { "bind-rdnc-confgen":
    command => "rndc-confgen -a -r /var/log/anaconda.syslog",
    path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin",
    require => Package['bind']
  }

  exec { "bind-rdnc-chmod":
    command => "chmod 666 /etc/rndc.key",
    path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin",
    require => Exec["bind-rdnc-confgen"]
  }

  exec { "bind-rdnc-chown":
    command => "chown named /etc/rndc.key",
    path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin",
    require => Exec["bind-rdnc-chmod"]
  }

  service { 'named':
    name       => 'named',
    ensure     => $status,
    enable     => $boot,
    hasrestart => true,
    hasstatus  => true,
    require    => Exec ['bind-rdnc-chown']
  }

  case $firewall {
    csf: {
      csf::port::open {'bind-firewall-csf-open': 
        port => $port
      }
    }
    iptables: {
      exec { "bind-firewall-iptables-add":
        command => "iptables -A INPUT -p udp --dport ${port} -j ACCEPT",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
        require => Package["bind"]
      }
      exec { "bind-firewall-iptables-save":
        command => "service iptables save",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
        require => Exec["bind-firewall-iptables-add"]
      }
    }
  }
}