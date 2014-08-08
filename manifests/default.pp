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
#include messaging

$db_root_pass = hiera('mysql_root_pass')

$keystone_db_user = hiera('keystone_db_user')
$keystone_db_pass = hiera('keystone_db_pass')

$openstack_admin_user = hiera('openstack_admin_user')
$openstack_admin_pass = hiera('openstack_admin_pass')

class {'::mysql::server':
	root_password    => $db_root_pass,
	override_options => {
		'mysqld' => {
			'bind-address' => "${::mgmt_ip}",
			'default-storage-engine' => 'innodb',
			'collation-server' => 'utf8_general_ci',
			'init-connect' => "'SET NAMES utf8'",
			'character-set-server' => "utf8",
		},
	},
	restart         => true,
	service_enabled => true,
}

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

$glance_service_user = hiera('glance_service_user')
$glance_service_pass = hiera('glance_service_pass')

$glance_db_user = hiera('glance_db_user')
$glance_db_pass = hiera('glance_db_pass')

class { 'glance::api':
	verbose             => true,
	keystone_tenant     => 'services',
	keystone_user       => $glance_service_user,
	keystone_password   => $glance_service_pass,
	database_connection => "mysql://${glance_db_user}:${glance_db_pass}@${mgmt_ip}/glance",
	mysql_module        => '2.3',
}

class { 'glance::registry':
	verbose             => true,
	keystone_tenant     => 'services',
	keystone_user       => $glance_service_user,
	keystone_password   => $glance_service_pass,
	database_connection => "mysql://${glance_db_user}:${glance_db_pass}@${mgmt_ip}/glance",
	mysql_module        => '2.3',
}

class { 'glance::backend::file': }

class { 'glance::db::mysql':
	password      => $glance_db_pass,
	user          => $glance_db_user,
	allowed_hosts => '%',
	mysql_module  => '2.3',
}

class { 'glance::keystone::auth':
	password         => $glance_service_pass,
	email            => 'glance@example.com',
	public_address   => $public_ip,
	admin_address    => $mgmt_ip,
	internal_address => $mgmt_ip,
}
