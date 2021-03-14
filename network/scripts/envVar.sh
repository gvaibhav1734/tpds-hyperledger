#!/bin/bash

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_CENTRALGOVERNMENT_CA=${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/ca.crt
export PEER0_STATEGOVERNMENTDEPOT_CA=${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/ca.crt
export PEER0_STATELEVELFPS_CA=${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/ca.crt
export PEER0_OTHER_CA=${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/ca.crt
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="centralgovernmentMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CENTRALGOVERNMENT_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/Admin@centralgovernment.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="stategovernmentdepotMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_STATEGOVERNMENTDEPOT_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/Admin@stategovernmentdepot.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="statelevelfpsMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_STATELEVELFPS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/statelevelfps.example.com/users/Admin@statelevelfps.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID="otherMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OTHER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/other.example.com/users/Admin@other.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
  
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.centralgovernment.example.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.stategovernmentdepot.example.com:8051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.statelevelfps.example.com:9051
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_ADDRESS=peer0.other.example.com:10051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    ORG_NAME=""

    if [ $1 -eq 1 ]; then
      ORG_NAME=CENTRALGOVERNMENT
    elif [ $1 -eq 2 ]; then
      ORG_NAME=STATEGOVERNMENTDEPOT
    elif [ $1 -eq 3 ]; then
      ORG_NAME=STATELEVELFPS
    elif [ $1 -eq 4 ]; then
      ORG_NAME=OTHER
    fi

    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_${ORG_NAME}_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
