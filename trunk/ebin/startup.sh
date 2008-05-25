#!/bin/sh
sudo killall beam.smp
erlc ../src/*.erl
mv ../src/*.beam .
sudo yaws --daemon --conf ../etc/yaws.conf
