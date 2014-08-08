class adminrc (
	$username = hiera('openstack_admin_user'),
	$password = hiera('openstack_admin_pass'),
	$tenant   = hiera('openstack_admin_pass'),
) {
	file { '/home/vagrant/adminrc.sh':
		ensure  => present,
		content => template('adminrc/adminrc.sh.erb'),
	}
}
