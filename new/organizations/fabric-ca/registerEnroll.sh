function createOrgs {
  echo
    echo "##########################################################"
    echo "##### Generate certificates using cryptogen tool #########"
    echo "##########################################################"
    echo

    echo "##########################################################"
    echo "############ Create centralgovernment Identities ######################"
    echo "##########################################################"
    pwd
    set -x
    cryptogen generate --config=../cryptogen/crypto-config-centralgovernment.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate certificates..."
      exit 1
    fi

    echo "##########################################################"
    echo "############ Create stategovernmentdepot Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=../cryptogen/crypto-config-stategovernmentdepot.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate certificates..."
      exit 1
    fi

    echo "##########################################################"
    echo "############ Create stategovernmentfps Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=../cryptogen/crypto-config-stategovernmentfps.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate certificates..."
      exit 1
    fi

    echo "##########################################################"
    echo "############ Create other Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=../cryptogen/crypto-config-other.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate certificates..."
      exit 1
    fi

    echo "##########################################################"
    echo "############ Create Orderer Org Identities ###############"
    echo "##########################################################"

    set -x
    cryptogen generate --config=../cryptogen/crypto-config-orderer.yaml --output="organizations"
    res=$?
    set +x
}


function createcentralgovernment {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/centralgovernment.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/centralgovernment.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-centralgovernment --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x

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
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-centralgovernment --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-centralgovernment --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-centralgovernment --id.name centralgovernmentadmin --id.secret centralgovernmentadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/centralgovernment.example.com/peers
  mkdir -p organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-centralgovernment -M ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/msp --csr.hosts peer0.centralgovernment.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-centralgovernment -M ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls --enrollment.profile tls --csr.hosts peer0.centralgovernment.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/tlsca/tlsca.centralgovernment.example.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/peers/peer0.centralgovernment.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/ca/ca.centralgovernment.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/centralgovernment.example.com/users
  mkdir -p organizations/peerOrganizations/centralgovernment.example.com/users/User1@centralgovernment.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-centralgovernment -M ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/User1@centralgovernment.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/User1@centralgovernment.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/centralgovernment.example.com/users/Admin@centralgovernment.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://centralgovernmentadmin:centralgovernmentadminpw@localhost:7054 --caname ca-centralgovernment -M ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/Admin@centralgovernment.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/centralgovernment/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/centralgovernment.example.com/users/Admin@centralgovernment.example.com/msp/config.yaml

}


function createstategovermentdepot {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/stategovermentdepot.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-stategovermentdepot --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovermentdepot.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovermentdepot.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovermentdepot.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-stategovermentdepot.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-stategovermentdepot --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-stategovermentdepot --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-stategovermentdepot --id.name stategovermentdepotadmin --id.secret stategovermentdepotadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/stategovermentdepot.example.com/peers
  mkdir -p organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-stategovermentdepot -M ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/msp --csr.hosts peer0.stategovermentdepot.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-stategovermentdepot -M ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls --enrollment.profile tls --csr.hosts peer0.stategovermentdepot.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/tlsca/tlsca.stategovermentdepot.example.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/peers/peer0.stategovermentdepot.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/ca/ca.stategovermentdepot.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/stategovermentdepot.example.com/users
  mkdir -p organizations/peerOrganizations/stategovermentdepot.example.com/users/User1@stategovermentdepot.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-stategovermentdepot -M ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/users/User1@stategovermentdepot.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/users/User1@stategovermentdepot.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/stategovermentdepot.example.com/users/Admin@stategovermentdepot.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://stategovermentdepotadmin:stategovermentdepotadminpw@localhost:8054 --caname ca-stategovermentdepot -M ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/users/Admin@stategovermentdepot.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/stategovermentdepot/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovermentdepot.example.com/users/Admin@stategovermentdepot.example.com/msp/config.yaml

}

function createstategovermentfps {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/createstategovermentfps.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-createstategovermentfps --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-createstategovermentfps.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-createstategovermentfps.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-createstategovermentfps.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-createstategovermentfps.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-createstategovermentfps --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-createstategovermentfps --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-createstategovermentfps --id.name createstategovermentfpsadmin --id.secret createstategovermentfpsadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/createstategovermentfps.example.com/peers
  mkdir -p organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-createstategovermentfps -M ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/msp --csr.hosts peer0.createstategovermentfps.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-createstategovermentfps -M ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls --enrollment.profile tls --csr.hosts peer0.createstategovermentfps.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/tlsca/tlsca.createstategovermentfps.example.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/peers/peer0.createstategovermentfps.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/ca/ca.createstategovermentfps.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/createstategovermentfps.example.com/users
  mkdir -p organizations/peerOrganizations/createstategovermentfps.example.com/users/User1@createstategovermentfps.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-createstategovermentfps -M ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/users/User1@createstategovermentfps.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/users/User1@createstategovermentfps.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/createstategovermentfps.example.com/users/Admin@createstategovermentfps.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://createstategovermentfpsadmin:createstategovermentfpsadminpw@localhost:9054 --caname ca-createstategovermentfps -M ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/users/Admin@createstategovermentfps.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/createstategovermentfps/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/createstategovermentfps.example.com/users/Admin@createstategovermentfps.example.com/msp/config.yaml

}

function createother {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/createother.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/createother.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-createother --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-createother.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-createother.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-createother.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-createother.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/createother.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-createother --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-createother --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-createother --id.name createotheradmin --id.secret createotheradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/createother.example.com/peers
  mkdir -p organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-createother -M ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/msp --csr.hosts peer0.createother.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/createother.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-createother -M ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls --enrollment.profile tls --csr.hosts peer0.createother.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/createother.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/createother.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/createother.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/createother.example.com/tlsca/tlsca.createother.example.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/createother.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/createother.example.com/peers/peer0.createother.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/createother.example.com/ca/ca.createother.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/createother.example.com/users
  mkdir -p organizations/peerOrganizations/createother.example.com/users/User1@createother.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-createother -M ${PWD}/organizations/peerOrganizations/createother.example.com/users/User1@createother.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/createother.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/createother.example.com/users/User1@createother.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/createother.example.com/users/Admin@createother.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://createotheradmin:createotheradminpw@localhost:10054 --caname ca-createother -M ${PWD}/organizations/peerOrganizations/createother.example.com/users/Admin@createother.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/createother/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/createother.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/createother.example.com/users/Admin@createother.example.com/msp/config.yaml

}

function createOrderer {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/ordererOrganizations/example.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

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
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml


  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

	mkdir -p organizations/ordererOrganizations/example.com/orderers
  mkdir -p organizations/ordererOrganizations/example.com/orderers/example.com

  mkdir -p organizations/ordererOrganizations/example.com/orderers/orderer.example.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:11054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:11054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p organizations/ordererOrganizations/example.com/users
  mkdir -p organizations/ordererOrganizations/example.com/users/Admin@example.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:11054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml


}

createOrgs
createcentralgovernment
createstategovernmentdepot
createstategovernmentfps
createother