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
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/centralgovernment.example.com/tlsca/tlsca.centralgovernment.example.com-cert.pem
CAPEM=organizations/peerOrganizations/centralgovernment.example.com/ca/ca.centralgovernment.example.com-cert.pem
pwd
echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/centralgovernment.example.com/connection-centralgovernment.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/centralgovernment.example.com/connection-centralgovernment.yaml

ORG=2
P0PORT=8051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/satetgovernmentdepot.example.com/tlsca/tlsca.satetgovernmentdepot.example.com-cert.pem
CAPEM=organizations/peerOrganizations/satetgovernmentdepot.example.com/ca/ca.satetgovernmentdepot.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/satetgovernmentdepot.example.com/connection-satetgovernmentdepot.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/satetgovernmentdepot.example.com/connection-satetgovernmentdepot.yaml

ORG=3
P0PORT=9051
CAPORT=9054
PEERPEM=organizations/peerOrganizations/satetgovernmentfps.example.com/tlsca/tlsca.satetgovernmentfps.example.com-cert.pem
CAPEM=organizations/peerOrganizations/satetgovernmentfps.example.com/ca/ca.satetgovernmentfps.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/satetgovernmentfps.example.com/connection-satetgovernmentfps.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/satetgovernmentfps.example.com/connection-satetgovernmentfps.yaml

ORG=4
P0PORT=10051
CAPORT=10054
PEERPEM=organizations/peerOrganizations/other.example.com/tlsca/tlsca.other.example.com-cert.pem
CAPEM=organizations/peerOrganizations/other.example.com/ca/ca.other.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/other.example.com/connection-other.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/other.example.com/connection-other.yaml
