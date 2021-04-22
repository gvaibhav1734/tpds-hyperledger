#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${P1PORT}/$6/" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${P1PORT}/$6/" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=centralgovernment
P0PORT=7051
P1PORT=7053
CAPORT=7054
PEERPEM=organizations/peerOrganizations/centralgovernment.example.com/tlsca/tlsca.centralgovernment.example.com-cert.pem
CAPEM=organizations/peerOrganizations/centralgovernment.example.com/ca/ca.centralgovernment.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/centralgovernment.example.com/connection-centralgovernment.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/centralgovernment.example.com/connection-centralgovernment.yaml

ORG=stategovernmentdepot
P0PORT=8051
P1PORT=8053
CAPORT=8054
PEERPEM=organizations/peerOrganizations/stategovernmentdepot.example.com/tlsca/tlsca.stategovernmentdepot.example.com-cert.pem
CAPEM=organizations/peerOrganizations/stategovernmentdepot.example.com/ca/ca.stategovernmentdepot.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/stategovernmentdepot.example.com/connection-stategovernmentdepot.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/stategovernmentdepot.example.com/connection-stategovernmentdepot.yaml

ORG=statelevelfps
P0PORT=9051
P1PORT=9053
CAPORT=9054
PEERPEM=organizations/peerOrganizations/statelevelfps.example.com/tlsca/tlsca.statelevelfps.example.com-cert.pem
CAPEM=organizations/peerOrganizations/statelevelfps.example.com/ca/ca.statelevelfps.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/statelevelfps.example.com/connection-statelevelfps.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/statelevelfps.example.com/connection-statelevelfps.yaml

ORG=other
P0PORT=10051
P1PORT=10053
CAPORT=10054
PEERPEM=organizations/peerOrganizations/other.example.com/tlsca/tlsca.other.example.com-cert.pem
CAPEM=organizations/peerOrganizations/other.example.com/ca/ca.other.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/other.example.com/connection-other.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > organizations/peerOrganizations/other.example.com/connection-other.yaml
