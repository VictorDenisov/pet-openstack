class database {
	$root_pass = hiera('mysql_root_pass')
	class {'::mysql::server':
		root_password    => "${root_pass}",
		override_options => {
			'mysqld'        => {
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
	mysql_database { 'test':
		ensure => 'present',
	}

	mysql_user { 'testUser@localhost':
		ensure => 'present'
	}

	mysql_grant { 'testUser@localhost/test.*':
		ensure     => 'present',
		options    => ['GRANT'],
		privileges => ['ALL'],
		table      => 'test.*',
		user       => 'testUser@localhost',
	}

	mysql_user { 'testUser@%':
		ensure => 'present'
	}

	mysql_grant { 'testUser@%/test.*':
		ensure     => 'present',
		options    => ['GRANT'],
		privileges => ['ALL'],
		table      => 'test.*',
		user       => 'testUser@%',
	}

	class { '::mysql::bindings':
		python_enable => true,
	}
}
