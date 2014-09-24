class profiles::external_ip {
	augeas { 'eth2':
		context => '/files/etc/network/interfaces',
		changes => [
			"set iface[. = \'eth2\']/method manual",
			"rm iface[. = \'eth2\']/address",
			"rm iface[. = \'eth2\']/netmask",
			],
	}
	augeas { 'interface-up':
		context => '/files/etc/network/interfaces',
		changes => [
			"insert up after iface[. = \'eth2\']/method",
			"set iface[. = \'eth2\']/up \'ip l s \$IFACE up\'",
			],
		onlyif => [
			"match iface[. = \'eth2\']/up size == 0",
			],
	}

	augeas { 'interface-down':
		context => '/files/etc/network/interfaces',
		changes => [
			"insert down after iface[. = \'eth2\']/up",
			"set iface[. = \'eth2\']/down \'ip l s \$IFACE down\'",
			],
		onlyif => [
			"match iface[. = \'eth2\']/down size == 0",
			],
	}

	augeas { 'add-br-ex':
		context => '/files/etc/network/interfaces',
		changes => [
			"insert auto after iface[last()]",
			"insert 1 after auto[last()]",
			"mv 1 auto[last()]/1",
			"set auto[last()]/1 br-ex",
			"insert iface after auto[last()]",
			"set iface[last()] br-ex",
			"set iface[. = \'br-ex\']/family inet",
			"set iface[. = \'br-ex\']/method static",
			"set iface[. = \'br-ex\']/address $public_ip",
			"set iface[. = \'br-ex\']/netmask 255.255.255.0",
			],
		onlyif => [
			"match auto/1[. = \'br-ex\'] size == 0",
			],
	}

	exec { 'clear-eth':
		command => '/sbin/ifconfig eth2 0.0.0.0 up',
	}

	exec { 'set-br-ex':
		command => "/sbin/ifconfig br-ex $public_ip/24 up",
	}

	Augeas['interface-up'] -> Augeas['interface-down']

}
