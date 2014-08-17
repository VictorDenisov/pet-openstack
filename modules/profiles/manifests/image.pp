class profiles::image {

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
            collate       => 'utf8_general_ci',
            mysql_module  => '2.3',
    }

    class { 'glance::keystone::auth':
	    auth_name        => $glance_service_user,
            password         => $glance_service_pass,
            email            => 'glance@example.com',
            public_address   => $public_ip,
            admin_address    => $mgmt_ip,
            internal_address => $mgmt_ip,
    }

}
