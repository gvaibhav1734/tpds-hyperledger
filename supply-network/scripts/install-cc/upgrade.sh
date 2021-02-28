#!/bin/bash
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export COMPOSE_PROJECT_NAME=supplynetwork

echo "Upgrade channel 1"
peer chaincode upgrade -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -l node -n supcc -v $1 -c '{"Args":[]}' >&log.txt
cat log.txt

echo "Upgrade channel 2"
peer chaincode upgrade -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA -C mychannel2 -l node -n supcc -v $1 -c '{"Args":[]}' >&log.txt
cat log.txt
