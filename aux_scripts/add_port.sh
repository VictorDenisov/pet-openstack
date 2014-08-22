#!/bin/bash

NAME=$1
PORT_ID=$2
MAC=$3

sudo ovs-vsctl add-port br-int $NAME -- set Interface $NAME type=internal -- set Interface $NAME external-ids:iface-id=$PORT_ID -- set Interface $NAME external-ids:attached-mac=$MAC
