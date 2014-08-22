#!/bin/bash

START_IP=172.30.1.9
END_IP=172.30.1.13

neutron net-create public --shared --router:external True --provider:network_type flat --provider:physical_network external
neutron subnet-create public --name public-subnet --allocation-pool start=$START_IP,end=$END_IP --disable-dhcp --gateway 172.30.1.1 172.30.1.0/24
neutron floatingip-create public
