#!/bin/bash

NET_ID=$1

nova boot --flavor m1.tiny --image cirros-0.3.2 vm1 --nic net-id=$NET_ID
