#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGMSP}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./connections/ccp-template.json 
}


ORG=fps
ORGMSP=Fps
P0PORT=7051
CAPORT=7054
PEERPEM=./supply-network/crypto-config/peerOrganizations/fps.example.com/tlsca/tlsca.fps.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/fps.example.com/ca/ca.fps.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-fps.json

ORG=centralgovernment
ORGMSP=CentralGovernment
P0PORT=9051
CAPORT=8054
PEERPEM=./supply-network/crypto-config/peerOrganizations/centralgovernment.example.com/tlsca/tlsca.centralgovernment.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/centralgovernment.example.com/ca/ca.centralgovernment.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-centralgovernment.json
ORG=depots
ORGMSP=Depots
P0PORT=10051
CAPORT=9054
PEERPEM=./supply-network/crypto-config/peerOrganizations/depots.example.com/tlsca/tlsca.depots.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/depots.example.com/ca/ca.depots.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-depots.json

ORG=fps
ORGMSP=FPS
P0PORT=11051
CAPORT=10054
PEERPEM=./supply-network/crypto-config/peerOrganizations/fps.example.com/tlsca/tlsca.fps.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/fps.example.com/ca/ca.fps.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-fps.json
