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

exec { '/usr/bin/apt-get update': }

include ntp
include database
include messaging
