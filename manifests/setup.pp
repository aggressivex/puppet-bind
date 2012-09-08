# Class: bind::setup
#
# This class installs bind for CentOS / RHEL
#
define bind::setup (
  $cutomSetup = {},
  $cutomConf  = {},
  $ensure     = installed,
  $boot       = true,
  $status     = 'running',
  $firewall   = false,
  $rdncGen    = true,
) {

  include conf
  $defaultConf = $conf::conf
  $defaultSetup = $conf::setup

  package { bind:
    ensure => $ensure,
  }

  $packages = ['bind-libs', 'bind-utils']

  package { $packages:
    ensure  => $ensure,
    require => Package['bind']
  }

  if $rdncGen == true {
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
  }

  service { 'named':
    name       => 'named',
    ensure     => $status,
    enable     => $boot,
    hasrestart => true,
    hasstatus  => true,
    require    => Exec ['bind-rdnc-chown']
  }

  file { "named-conf-zones":
    path    => "/etc/named.custom.zones",
    owner   => root,
    group   => named,
    mode    => 644,
    content => template($defaultSetup['template-custom-zones']),
    require => Package['bind'],
    notify  => Service['named'],
  }

  file { "named-conf-file":
    path    => "/etc/named.conf",
    owner   => root,
    group   => named,
    mode    => 644,
    content => template($defaultSetup['template-named-conf']),
    require => Package['bind'],
    notify  => Service['named'],
  }

  case $firewall {
    csf: {
      csf::port::open {'bind-firewall-csf-open': 
        port => $defaultSetup['port']
      }
    }
    iptables: {
      exec { "bind-firewall-iptables-add":
        command => "iptables -I INPUT 5 -p udp --dport ${port} -j ACCEPT",
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