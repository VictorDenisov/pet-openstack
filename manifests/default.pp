exec { '/usr/bin/apt-get update': }

include ntp
include messaging

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

#include profiles::image

$messaging_user = hiera('rabbitmq_user')
$messaging_pass = hiera('rabbitmq_pass')

$neutron_db_user = hiera('neutron_db_user')
$neutron_db_pass = hiera('neutron_db_pass')

$neutron_service_user = hiera('neutron_service_user')
$neutron_service_pass = hiera('neutron_service_pass')

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
	type_drivers         => ['vlan'],
	tenant_network_types => ['vlan'],
	mechanism_drivers     => ['openvswitch'],
}

class { 'neutron::agents::ml2::ovs':
	bridge_mappings => ['private:br-eth3'],
}

class { 'neutron::agents::l3': }

class { 'neutron::agents::dhcp': }

vs_port { 'eth3':
	ensure => present,
	bridge => 'br-eth3',
}

vs_bridge { 'br-ex':
	ensure => present,
}

vs_port { 'eth2':
	ensure => present,
	bridge => 'br-ex',
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

#class { 'neutron::agents::metadata':
#auth_user     => $neutron_service_user,
#auth_password => $neutron_service_pass,
#}
