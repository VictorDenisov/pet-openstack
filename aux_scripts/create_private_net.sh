#!/bin/bash

neutron net-create net1
neutron subnet-create net1 --name subnet1 10.0.0.0/24
