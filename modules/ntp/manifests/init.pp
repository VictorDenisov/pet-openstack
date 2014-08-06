class ntp {
	package { 'ntp' :
		ensure => present,
	}
	class { 'timezone' :
		timezone => 'UTC',
	}
}
