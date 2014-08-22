#!/bin/bash

NAME=$1
PORT_NAME=$2
IP_ADDR=$3
GATEWAY=$4

ip netns add $NAME
ip link set $PORT_NAME netns $NAME

#ip netns exec $NAME ifconfig $PORT_NAME $IP_ADDR up

#ip netns exec $NAME ip ro add default via $GATEWAY
