class profiles::dashboard {

	class { 'horizon':
		secret_key         => 'secret_key',
		fqdn               => '*',
		cache_server_ip    => $mgmt_ip,
		keystone_url       => "http://${mgmt_ip}:5000/v2.0",
		bind_address       => '0.0.0.0',
		vhost_extra_params => { 'add_listen' => false },
	}

	class { 'memcached': }
}
