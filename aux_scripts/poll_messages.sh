#!/bin/bash

for i in `seq 1 $1`; do
	./rabbitmqadmin get queue=conductor_test_vdenisov requeue=false payload_file=out --username=rabbit --password=bunny
	if [[ $? -eq 0 ]]; then
		cat out >> ttt.txt
		echo "--------" >> ttt.txt
	fi
done
