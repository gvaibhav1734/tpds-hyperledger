#!/bin/bash

./network.sh up -ca
./network.sh createChannel -c channel1
./network.sh deployCC -ccn tpds -ccp ../chaincode/ -ccl javascript -c channel1
./network.sh createChannel2 -c channel2
./network.sh deployCC2 -ccn tpds2 -ccp ../chaincode/ -ccl javascript -c channel2