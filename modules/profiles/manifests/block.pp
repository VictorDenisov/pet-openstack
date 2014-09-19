class profiles::block {

	$messaging_user = hiera('rabbitmq_user')
	$messaging_pass = hiera('rabbitmq_pass')

	$cinder_db_user = hiera('cinder_db_user')
	$cinder_db_pass = hiera('cinder_db_pass')

	$cinder_service_user = hiera('cinder_service_user')
	$cinder_service_pass = hiera('cinder_service_user')

	class { 'cinder':
		database_connection => "mysql://$cinder_db_user:$cinder_db_pass@${mgmt_ip}/cinder?charset=utf8",
		rabbit_host         => $mgmt_ip,
		rabbit_userid       => $messaging_user,
		rabbit_password     => $messaging_pass,
		mysql_module        => '2.3',
	}

	class { 'cinder::db::mysql':
		password      => $cinder_db_pass,
		user          => $cinder_db_user,
		host          => $mgmt_ip,
		allowed_hosts => '%',
		charset       => 'utf8',
		collate       => 'utf8_general_ci',
		mysql_module  => '2.3',
	}

	class { 'cinder::api':
		keystone_password  => $cinder_service_pass,
		keystone_user      => $cinder_service_user,
		keystone_auth_host => $mgmt_ip,
	}

	class { 'cinder::keystone::auth':
		password         => $cinder_service_pass,
		auth_name        => $cinder_service_user,
		public_address   => $public_ip,
		admin_address    => $mgmt_ip,
		internal_address => $mgmt_ip,
	}

	class { 'cinder::scheduler':
		scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
	}

	class { 'cinder::volume':
		require => Volume_group['cinder-volumes'],
	}

	class { 'cinder::volume::iscsi':
		iscsi_ip_address => $mgmt_ip,
	}

	file { '/var/lib/cinder/cinder.sqlite':
		ensure => absent,
	}

	physical_volume { '/dev/sdb':
		ensure => present,
	}

	volume_group { 'cinder-volumes':
		ensure           => present,
		physical_volumes => '/dev/sdb',
	}
}
