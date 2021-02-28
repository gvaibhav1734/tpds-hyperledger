#!/bin/bash
echo "Creating channel..."
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CORE_PEER_LOCALMSPID=FPSMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fps.example.com/peers/peer0.fps.example.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fps.example.com/users/Admin@fps.example.com/msp
CORE_PEER_ADDRESS=peer0.fps.example.com:11051
CHANNEL_NAME=mychannel
CORE_PEER_TLS_ENABLED=true
ORDERER_SYSCHAN_ID=syschain
echo "Create channel 1"
peer channel create -o  orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
cat log.txt

CHANNEL_NAME=mychannel2
echo "Create channel 2"
peer channel create -o  orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel2.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
cat log.txt


#peer channel create -o orderer.example.com:7050 /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -c mychannel -f ./channel-artifacts/channel.tx

# echo 
# echo "Channel created, joining Fps..."
# peer channel join -b mychannel.block