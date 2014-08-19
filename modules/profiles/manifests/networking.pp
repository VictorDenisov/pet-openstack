class profiles::networking {
	$messaging_user = hiera('rabbitmq_user')
	$messaging_pass = hiera('rabbitmq_pass')

	$neutron_db_user = hiera('neutron_db_user')
	$neutron_db_pass = hiera('neutron_db_pass')

	$neutron_service_user = hiera('neutron_service_user')
	$neutron_service_pass = hiera('neutron_service_pass')

	$metadata_shared_secret = hiera('metadata_shared_secret')

	class { 'neutron::db::mysql':
		user          => $neutron_db_user,
		password      => $neutron_db_pass,
		host          => $mgmt_ip,
		collate       => 'utf8_general_ci',
		mysql_module  => '2.3',
		allowed_hosts => '%',
	}

	class { 'neutron::keystone::auth':
		auth_name        => $neutron_service_user,
		password         => $neutron_service_pass,
		public_address   => $public_ip,
		admin_address    => $mgmt_ip,
		internal_address => $mgmt_ip,
	}

	class { 'neutron':
		verbose               => true,
		rabbit_host           => $mgmt_ip,
		rabbit_user           => $messaging_user,
		rabbit_password       => $messaging_pass,
		allow_overlapping_ips => true,
		service_plugins       => ['router'],
		core_plugin           => 'ml2',
	}

	class { 'neutron::server':
		auth_user           => $neutron_service_user,
		auth_password       => $neutron_service_pass,
		auth_host           => $mgmt_ip,
		auth_port           => 5000,
		database_connection => "mysql://${neutron_db_user}:${neutron_db_pass}@${mgmt_ip}/neutron?charset=utf8",
		mysql_module        => '2.3',
	}

	class { 'neutron::plugins::ml2':
		type_drivers         => ['flat', 'vlan'],
		tenant_network_types => ['vlan'],
		mechanism_drivers    => ['openvswitch'],
		flat_networks        => ['external'],
		network_vlan_ranges  => ['private:1000:2999'],
	}

	class { 'neutron::agents::ml2::ovs':
		bridge_mappings => ['private:br-eth3', 'external:br-ex'],
	}

	class { 'neutron::agents::l3': }

	class { 'neutron::agents::dhcp': }

	vs_port { 'eth3':
		ensure => present,
		bridge => 'br-eth3',
	}

	vs_port { 'eth2':
		ensure => present,
		bridge => 'br-ex',
		notify => Exec['set-br-ex'],
	}

	augeas { "routing":
		changes => [ "set /files/etc/sysctl.conf/net.ipv4.ip_forward 1",
			     "set /files/etc/sysctl.conf/net.ipv4.conf.all.rp_filter 0",
			     "set /files/etc/sysctl.conf/net.ipv4.conf.default.rp_filter 0",
		],
		notify => Exec['sysctl'],
	}

	exec { 'sysctl':
		command => '/sbin/sysctl -p',
	}


	augeas { 'external-ip':
		context => '/files/etc/network/interfaces',
		changes => [
			"set iface[. = \'eth2\']/method manual",
			"insert up after iface[. = \'eth2\']/method",
			"insert down after iface[. = \'eth2\']/up",
			"set iface[. = \'eth2\']/up \'ip l s \$IFACE up\'",
			"set iface[. = \'eth2\']/down \'ip l s \$IFACE down\'",
			"rm iface[. = \'eth2\']/address",
			"rm iface[. = \'eth2\']/netmask",

			"insert auto after iface[last()]",
			"insert 1 after auto[last()]",
			"mv 1 auto[last()]/1",
			"set auto[last()]/1 br-ex",
			"insert iface after auto[last()]",
			"set iface[last()] br-ex",
			"set iface[. = \'br-ex\']/family inet",
			"set iface[. = \'br-ex\']/method static",
			"set iface[. = \'br-ex\']/address $public_ip",
			"set iface[. = \'br-ex\']/netmask 255.255.255.0",
			],
		notify => Exec['clear-eth'],
	}

	exec { 'clear-eth':
		command => '/sbin/ifconfig eth2 0.0.0.0 up',
		notify => Exec['set-br-ex'],
	}

	exec { 'set-br-ex':
		command => "/sbin/ifconfig br-ex $public_ip up",
	}

	class { 'neutron::agents::metadata':
		auth_user     => $neutron_service_user,
		auth_password => $neutron_service_pass,
		shared_secret => $metadata_shared_secret,
	}
}
