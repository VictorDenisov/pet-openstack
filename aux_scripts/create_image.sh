#!/bin/bash

IMAGE_NAME=cirros-0.3.2

glance image-create --name $IMAGE_NAME --disk-format qcow2 --container-format bare --is-public true --file ./cirros-0.3.2-x86_64-disk.img --progress
glance image-update $IMAGE_NAME --property architecture=x86_64 --property hypervisor_type=qemu
