augeas { "sshd_config":
	changes => [ "set /files/etc/ssh/sshd_config/PermitRootLogin yes",
	],
}

package { 'openvswitch-switch':
	ensure => present,
}

vs_bridge { 'br-ex':
	ensure => present,
}

$value = hiera('mysql_root_pass')
notify { "The user password is: ${value}": }

exec { '/usr/bin/apt-get update': }

include ntp
include database
