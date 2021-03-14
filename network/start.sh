#!/bin/bash

./network.sh up
./network.sh createChannel
./network.sh deployCC -ccn tpds -ccp ../chaincode/ -ccl javascript