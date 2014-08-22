#!/bin/bash

neutron router-create router1
neutron router-gateway-set router1 public
neutron router-interface-add router1 subnet1
