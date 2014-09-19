Pet Openstack
=============

Pet Openstack is a one node deployment of openstack designed for use under
Vagrant. It allows you to learn and modify your openstack without thinking
about how to recover your openstack if everything falls apart as a result of
your experiments.

This configuration is derived from course material of Openstack Training OS200
created by Polina Petriuk.

Version Control
---------------

https://github.com/VictorDenisov/pet-openstack

Installation
============

This deployment is tested with Vagrant version 1.5.3. Most likely you will need
to download the latest version of Vagrant from their website -
http://www.vagrantup.com/downloads.html

After you installed vagrant you can type:

$ vagrant up

and your openstack node should be ready in about half of an hour.

Cinder
------

If you don't need cinder then before running vagrant just remove include
profiles::block from manifests/default.pp.

Network Folder
--------------

By default Pet Openstack mounts your project directory to /vagrant on your vm
with Pet Openstack.  It requires package nfsd. However this feature is not
vital to your Pet Openstack. You can delete this line

> config.vm.synced_folder ".", "/vagrant", nfs: true

from Vagrant file if you have issues configuring nfs folder. Then you will need
to upload cirros image from your host machine to the vm with Pet Openstack.
