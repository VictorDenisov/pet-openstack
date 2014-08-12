exec { '/usr/bin/apt-get update': }

include ntp
#include messaging

$db_root_pass = hiera('mysql_root_pass')

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

include profiles::identity

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

$messaging_user = hiera('rabbitmq_user')
$messaging_pass = hiera('rabbitmq_pass')

class { 'neutron':
	verbose               => true,
	bind_host             => $mgmt_ip,
	rabbit_host           => $mgmt_ip,
	rabbit_user           => $messaging_user,
	rabbit_password       => $messaging_pass,
	allow_overlapping_ips => true,
}

$neutron_service_user = hiera('neutron_service_user')
$neutron_service_pass = hiera('neutron_service_pass')

$neutron_db_user = hiera('neutron_db_user')
$neutron_db_pass = hiera('neutron_db_pass')

#class { 'neutron::server':
#auth_user           => $neutron_service_user,
#auth_password       => $neutron_service_pass,
#auth_host           => $mgmt_ip,
#database_connection => "mysql://${neutron_db_user}:${neutron_db_pass}@${mgmt_ip}/neutron?charset=utf8",
#mysql_module        => '2.3',
#}

#class { 'neutron::plugins::ml2':
#type_drivers         => ['vlan'],
#tenant_network_types => ['vlan'],
#}

#class { 'neutron::agents::dhcp': }
#class { 'neutron::agents::l3': }

#class { 'neutron::agents::metadata':
#auth_user     => $neutron_service_user,
#auth_password => $neutron_service_pass,
#}
