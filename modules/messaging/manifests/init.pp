class messaging {
	$messaging_user = hiera('rabbitmq_user')
	$messaging_pass = hiera('rabbitmq_pass')

	class { 'rabbitmq':
		version => '3.3.4',
	}

	rabbitmq_user { $messaging_user:
		admin    => true,
		password => $messaging_pass,
	}

	rabbitmq_user_permissions { "${messaging_user}@/":
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
	}
}
