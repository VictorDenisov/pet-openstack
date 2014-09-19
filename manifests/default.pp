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

include profiles::image

include profiles::networking

include profiles::compute

include profiles::dashboard

include profiles::block
