#!/bin/bash

setGlobals() {
  ORG=$1
  if [ $ORG -eq 1 ]; then
    CORE_PEER_LOCALMSPID="centralgovernmentMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=../organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/centralgovernment.example.com/users/Admin@centralgovernment.example.com/msp
    CORE_PEER_ADDRESS=centralgovernment.example.com:7051
  elif [ $ORG -eq 2 ]; then
    CORE_PEER_LOCALMSPID="stategovernmentdepotMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=../organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/stategovernmentdepot.example.com/users/Admin@stategovernmentdepot.example.com/msp
    CORE_PEER_ADDRESS=0.0.0.0:8051
  elif [ $ORG -eq 3 ]; then
    CORE_PEER_LOCALMSPID="stategovernmentfpsMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=../organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/stategovernmentfps.example.com/users/Admin@stategovernmentfps.example.com/msp
    CORE_PEER_ADDRESS=0.0.0.0:9051
  elif [ $ORG -eq 4 ]; then
    CORE_PEER_LOCALMSPID="otherMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=../organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=../organizations/peerOrganizations/other.example.com/users/Admin@other.example.com/msp
    CORE_PEER_ADDRESS=0.0.0.0:10051
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

createChannelTx() {
  set -x
	configtxgen -profile OrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate channel configuration transaction..."
		exit 1
	fi
	echo
}

createAncorPeerTx() {
  echo "#######    Generating anchor peer update transaction for ${orgmsp}  ##########"
	set -x
  orgmsp=$CORE_PEER_LOCALMSPID
	configtxgen -profile OrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate anchor peer update transaction for ${orgmsp}..."
		exit 1
	fi
	echo
}

joinChannel() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	echo
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

updateAnchorPeers() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
		peer channel update -o 0.0.0.0:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
  sleep $DELAY
  echo
}

createChannel() {
	setGlobals 1
  echo $CORE_PEER_ADDRESS
  set -x
  peer channel create -o 0.0.0.0:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA >&log.txt
  res=$?
  set +x
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

declare -a channels=("mychannel1" "mychannel2")
ls
pwd
echo $CORE_PEER_ADDRESS
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
for channel in "${channels[@]}"; do
  CHANNEL_NAME=$channel
  FABRIC_CFG_PATH=${PWD}/configtx

  ## Create channeltx
  echo "### Generating channel create transaction '${CHANNEL_NAME}.tx' ###"
  createChannelTx

  ## Create anchorpeertx
  echo "### Generating anchor peer update transactions ###"
  createAncorPeerTx

  # FABRIC_CFG_PATH=$PWD/../config/
  ## Create channel
  echo "Creating channel "$CHANNEL_NAME
  createChannel

  ## Join all the peers to the channel
  echo "Join Org1 peers to the channel..."
  joinChannel 1
  echo "Join Org2 peers to the channel..."
  joinChannel 2
  echo "Join Org3 peers to the channel..."
  joinChannel 3
  echo "Join Org4 peers to the channel..."
  joinChannel 4

  ## Set the anchor peers for each org in the channel
  echo "Updating anchor peers for org1..."
  updateAnchorPeers 1
  echo "Updating anchor peers for org2..."
  updateAnchorPeers 2

  echo
  echo "========= Channel successfully joined =========== "
  echo
done

exit 0