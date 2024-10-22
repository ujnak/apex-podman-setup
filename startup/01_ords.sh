#!/bin/sh

nohup /usr/local/bin/ords --config /etc/ords/config serve > /home/oracle/ords.log 2>&1 &