class profiles::compute {

	$nova_service_user = hiera('nova_service_user')
	$nova_service_pass = hiera('nova_service_pass')

	$neutron_service_user = hiera('neutron_service_user')
	$neutron_service_pass = hiera('neutron_service_pass')

	$nova_db_user = hiera('nova_db_user')
	$nova_db_pass = hiera('nova_db_pass')

	$messaging_user = hiera('rabbitmq_user')
	$messaging_pass = hiera('rabbitmq_pass')

	$metadata_shared_secret = hiera('metadata_shared_secret')

	class { 'nova::db::mysql':
		user          => $nova_db_user,
		password      => $nova_db_pass,
		host          => $mgmt_ip,
		allowed_hosts => '%',
		collate       => 'utf8_general_ci',
		mysql_module  => '2.3'
	}

	class { 'nova::keystone::auth':
		auth_name              => $nova_service_user,
		password               => $nova_service_pass,
		public_address         => $public_ip,
		admin_address          => $mgmt_ip,
		internal_address       => $mgmt_ip,
		configure_ec2_endpoint => false,
		configure_endpoint_v3  => false,
	}

	class { 'nova':
		database_connection => "mysql://$nova_db_user:$nova_db_pass@$mgmt_ip/nova?charset=utf8",
		glance_api_servers  => "$mgmt_ip:9292",
		rabbit_host         => $mgmt_ip,
		rabbit_userid       => $messaging_user,
		rabbit_password     => $messaging_pass,
		mysql_module        => '2.3',
		notify              => Exec['readable_kernel'],
	}

	class { 'nova::compute':
		enabled                       => true,
		vncserver_proxyclient_address => $mgmt_ip,
		vncproxy_host                 => $mgmt_ip,
	}

	class { 'nova::conductor':
		enabled => true,
	}

	class { 'nova::scheduler':
		enabled => true,
	}

	class { 'nova::consoleauth':
		enabled => true,
	}

	class { 'nova::vncproxy':
		enabled => true,
		host    => $mgmt_ip,
	}

	class { 'nova::compute::libvirt':
		vncserver_listen  => $mgmt_ip,
		libvirt_virt_type => 'qemu',
	}

	class { 'nova::network::neutron':
		neutron_admin_username => $neutron_service_user,
		neutron_admin_password => $neutron_service_pass,
		neutron_url            => "http://$mgmt_ip:9696",
		neutron_admin_auth_url => "http://$mgmt_ip:5000/v2.0",
		vif_plugging_is_fatal  => false,
		vif_plugging_timeout   => '10',
	}

	class { 'nova::api':
		admin_user                           => $nova_service_user,
		admin_password                       => $nova_service_pass,
		enabled                              => true,
		auth_host                            => $mgmt_ip,
		auth_port                            => 5000,
		neutron_metadata_proxy_shared_secret => $metadata_shared_secret,
	}

	exec { 'readable_kernel':
		command => '/usr/bin/dpkg-statoverride --update --add root root 0644 /boot/vmlinuz-3.13.0-*',
		before  => File['statoverride'],
	}

	file { 'statoverride':
		path   => '/etc/kernel/postinst.d/statoverride',
		ensure => present,
		mode   => 0755,
		source => 'puppet:///modules/profiles/statoverride',
	}
}
