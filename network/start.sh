#!/bin/bash

./network.sh up -ca
./network.sh createChannel
./network.sh deployCC -ccn tpds -ccp ../chaincode/ -ccl javascript