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

include test
