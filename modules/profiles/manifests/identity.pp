class profiles::identity {

	$keystone_db_user = hiera('keystone_db_user')
	$keystone_db_pass = hiera('keystone_db_pass')

	$openstack_admin_user = hiera('openstack_admin_user')
	$openstack_admin_pass = hiera('openstack_admin_pass')

	class { 'keystone':
		verbose             => true,
		catalog_type        => 'sql',
		admin_token         => 'ADMIN',
		database_connection => 'mysql://keystoneUser:keystonePass@localhost/keystone',
		mysql_module        => '2.3',
	}

	class { 'keystone::roles::admin':
		email        => 'admin@example.com',
		password     => $openstack_admin_pass,
		admin        => $openstack_admin_user,
		admin_tenant => 'admin',
	}

	# Installs the service user endpoint.
	class { 'keystone::endpoint':
		public_url   => "http://${public_ip}:5000",
		admin_url    => "http://${mgmt_ip}:35357",
		internal_url => "http://${mgmt_ip}:5000",
	}

	class { 'keystone::db::mysql':
		user          => $keystone_db_user,
		password      => $keystone_db_pass,
		mysql_module  => '2.3',
		allowed_hosts => '%',
	}

	include adminrc

}
