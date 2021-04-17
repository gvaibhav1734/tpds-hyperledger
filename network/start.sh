#!/bin/bash

./network.sh up -ca
./network.sh createChannel -c channel1
./network.sh deployCC -ccn tpds -ccp ../chaincode/ -ccl javascript -c channel1