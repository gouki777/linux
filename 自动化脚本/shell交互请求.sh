#!/bin/bash
#清理24h不用的image
(sleep 1
echo "y"
sleep 1)|docker image prune -a --filter "until=24h"
#清理24h不用的docker网络
(sleep 1
echo "y"
sleep 1)|docker network prune --filter "until=24h"