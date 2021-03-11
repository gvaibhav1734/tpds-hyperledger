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
    cryptogen generate --config=./organizations/cryptogen/crypto-config-centralgovernment.yaml --output="organizations"
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
    cryptogen generate --config=./organizations/cryptogen/crypto-config-stategovernmentdepot.yaml --output="organizations"
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
    cryptogen generate --config=./organizations/cryptogen/crypto-config-stategovernmentfps.yaml --output="organizations"
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
    cryptogen generate --config=./organizations/cryptogen/crypto-config-other.yaml --output="organizations"
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
    cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
    res=$?
    set +x
}


function createCentralgovernment {

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
    Certificate: cacerts/ca.centralgovernment.example.com-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.centralgovernment.example.com-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.centralgovernment.example.com-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.centralgovernment.example.com-cert.pem
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


function createStategovernmentdepot {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/stategovernmentdepot.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-stategovernmentdepot --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.stategovernmentdepot.example.com-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.stategovernmentdepot.example.com-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.stategovernmentdepot.example.com-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.stategovernmentdepot.example.com-cert.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-stategovernmentdepot --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-stategovernmentdepot --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-stategovernmentdepot --id.name stategovernmentdepotadmin --id.secret stategovernmentdepotadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/stategovernmentdepot.example.com/peers
  mkdir -p organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-stategovernmentdepot -M ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/msp --csr.hosts peer0.stategovernmentdepot.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-stategovernmentdepot -M ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls --enrollment.profile tls --csr.hosts peer0.stategovernmentdepot.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/tlsca/tlsca.stategovernmentdepot.example.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/peers/peer0.stategovernmentdepot.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/ca/ca.stategovernmentdepot.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/stategovernmentdepot.example.com/users
  mkdir -p organizations/peerOrganizations/stategovernmentdepot.example.com/users/User1@stategovernmentdepot.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-stategovernmentdepot -M ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/User1@stategovernmentdepot.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/User1@stategovernmentdepot.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/stategovernmentdepot.example.com/users/Admin@stategovernmentdepot.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://stategovernmentdepotadmin:stategovernmentdepotadminpw@localhost:8054 --caname ca-stategovernmentdepot -M ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/Admin@stategovernmentdepot.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentdepot/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovernmentdepot.example.com/users/Admin@stategovernmentdepot.example.com/msp/config.yaml

}

function createStategovernmentfps {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/stategovernmentfps.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-stategovernmentfps --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.stategovernmentfps.example.com-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.stategovernmentfps.example.com-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.stategovernmentfps.example.com-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.stategovernmentfps.example.com-cert.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-stategovernmentfps --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-stategovernmentfps --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-stategovernmentfps --id.name stategovernmentfpsadmin --id.secret stategovernmentfpsadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/stategovernmentfps.example.com/peers
  mkdir -p organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-stategovernmentfps -M ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/msp --csr.hosts peer0.stategovernmentfps.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-stategovernmentfps -M ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls --enrollment.profile tls --csr.hosts peer0.stategovernmentfps.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/tlsca/tlsca.stategovernmentfps.example.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/peers/peer0.stategovernmentfps.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/ca/ca.stategovernmentfps.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/stategovernmentfps.example.com/users
  mkdir -p organizations/peerOrganizations/stategovernmentfps.example.com/users/User1@stategovernmentfps.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-stategovernmentfps -M ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/users/User1@stategovernmentfps.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/users/User1@stategovernmentfps.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/stategovernmentfps.example.com/users/Admin@stategovernmentfps.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://stategovernmentfpsadmin:stategovernmentfpsadminpw@localhost:9054 --caname ca-stategovernmentfps -M ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/users/Admin@stategovernmentfps.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/stategovernmentfps/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/stategovernmentfps.example.com/users/Admin@stategovernmentfps.example.com/msp/config.yaml

}

function createOther {

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
    Certificate: cacerts/ca.createother.example.com-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.createother.example.com-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.createother.example.com-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.createother.example.com-cert.pem
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
    Certificate: cacerts/ca.orderer.example.com-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.orderer.example.com-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.orderer.example.com-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.orderer.example.com-cert.pem
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

# createOrgs
# createcentralgovernment
# createstategovernmentdepot
# createstategovernmentfps
# createother