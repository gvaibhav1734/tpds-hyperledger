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


ORG=centralgovernment
ORGMSP=CentralGovernment
P0PORT=7051
CAPORT=7054
PEERPEM=./supply-network/crypto-config/peerOrganizations/centralgovernment.example.com/tlsca/tlsca.centralgovernment.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/centralgovernment.example.com/ca/ca.centralgovernment.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-centralgovernment.json

ORG=stategovernmentdepot
ORGMSP=StateGovernmentDepot
P0PORT=9051
CAPORT=8054
PEERPEM=./supply-network/crypto-config/peerOrganizations/stategovernmentdepot.example.com/tlsca/tlsca.stategovernmentdepot.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/stategovernmentdepot.example.com/ca/ca.stategovernmentdepot.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-stategovernmentdepot.json

ORG=stategovernmentfps
ORGMSP=StateGovernmentFPS
P0PORT=10051
CAPORT=9054
PEERPEM=./supply-network/crypto-config/peerOrganizations/stategovernmentfps.example.com/tlsca/tlsca.stategovernmentfps.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/stategovernmentfps.example.com/ca/ca.stategovernmentfps.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-stategovernmentfps.json

ORG=other
ORGMSP=Other
P0PORT=11051
CAPORT=10054
PEERPEM=./supply-network/crypto-config/peerOrganizations/other.example.com/tlsca/tlsca.other.example.com-cert.pem
CAPEM=./supply-network/crypto-config/peerOrganizations/other.example.com/ca/ca.other.example.com-cert.pem

echo "$(json_ccp $ORG $ORGMSP $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./connections/connection-other.json
