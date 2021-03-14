#!/bin/bash

function createcentralgovernment() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/centralgovernment.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/centralgovernment.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-centralgovernment --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centralgovernment.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centralgovernment.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centralgovernment.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-centralgovernment.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-centralgovernment --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-centralgovernment --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-centralgovernment --id.name centralgovernmentadmin --id.secret centralgovernmentadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-centralgovernment -M "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/msp" --csr.hosts peer0.centralgovernment.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-centralgovernment -M "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls" --enrollment.profile tls --csr.hosts peer0.centralgovernment.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/tlsca/tlsca.centralgovernment.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/ca/ca.centralgovernment.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-centralgovernment -M "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/User1@centralgovernment.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/User1@centralgovernment.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://centralgovernmentadmin:centralgovernmentadminpw@localhost:7054 --caname ca-centralgovernment -M "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/Admin@centralgovernment.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/Admin@centralgovernment.example.com/msp/config.yaml"
}

function createstategovernmentdepot() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/stategovernmentdepot.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-stategovernmentdepot --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovernmentdepot.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovernmentdepot.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovernmentdepot.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovernmentdepot.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-stategovernmentdepot --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-stategovernmentdepot --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-stategovernmentdepot --id.name stategovernmentdepotadmin --id.secret stategovernmentdepotadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-stategovernmentdepot -M "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/msp" --csr.hosts peer0.stategovernmentdepot.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-stategovernmentdepot -M "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls" --enrollment.profile tls --csr.hosts peer0.stategovernmentdepot.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/tlsca/tlsca.stategovernmentdepot.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/ca/ca.stategovernmentdepot.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-stategovernmentdepot -M "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/User1@stategovernmentdepot.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/User1@stategovernmentdepot.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://stategovernmentdepotadmin:stategovernmentdepotadminpw@localhost:8054 --caname ca-stategovernmentdepot -M "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/Admin@stategovernmentdepot.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/Admin@stategovernmentdepot.example.com/msp/config.yaml"
}

function createstatelevelfps() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/statelevelfps.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/statelevelfps.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-statelevelfps --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-statelevelfps.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-statelevelfps.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-statelevelfps.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-statelevelfps.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-statelevelfps --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-statelevelfps --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-statelevelfps --id.name statelevelfpsadmin --id.secret statelevelfpsadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-statelevelfps -M "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/msp" --csr.hosts peer0.statelevelfps.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-statelevelfps -M "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls" --enrollment.profile tls --csr.hosts peer0.statelevelfps.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/tlsca/tlsca.statelevelfps.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/peers/peer0.statelevelfps.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/ca/ca.statelevelfps.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-statelevelfps -M "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/users/User1@statelevelfps.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/users/User1@statelevelfps.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://statelevelfpsadmin:statelevelfpsadminpw@localhost:9054 --caname ca-statelevelfps -M "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/users/Admin@statelevelfps.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/statelevelfps/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/statelevelfps.example.com/users/Admin@statelevelfps.example.com/msp/config.yaml"
}

function createother() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/other.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/other.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-other --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-other.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-other.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-other.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-other.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/other.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-other --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-other --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-other --id.name otheradmin --id.secret otheradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-other -M "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/msp" --csr.hosts peer0.other.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/other.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-other -M "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls" --enrollment.profile tls --csr.hosts peer0.other.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/other.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/other.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/other.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/other.example.com/tlsca/tlsca.other.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/other.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/other.example.com/peers/peer0.other.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/other.example.com/ca/ca.other.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-other -M "${PWD}/organizations/peerOrganizations/other.example.com/users/User1@other.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/other.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/other.example.com/users/User1@other.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://otheradmin:otheradminpw@localhost:10054 --caname ca-other -M "${PWD}/organizations/peerOrganizations/other.example.com/users/Admin@other.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/other/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/other.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/other.example.com/users/Admin@other.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:11054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:11054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:11054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}