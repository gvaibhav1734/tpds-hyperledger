export IMAGE_TAG=2.3
export IMAGE_TAG_CA=1.4.9
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
COMPOSE_FILE_NET=docker/docker-compose-net.yaml
CLI_FILE=docker/docker-compose-cli.yaml
INTERACTIVE=''

function networkUp {
  rm log.txt
  # Spawn cli container to generate crypt stuff for CA's
  docker-compose -f $CLI_FILE up -d > log.txt 2>&1 --remove-orphans
  docker-compose -f $COMPOSE_FILE_NET up -d > log.txt 2>&1 --remove-orphans
  cat log.txt
  echo
  echo
  echo
  echo
  # THe function which generates all crypt stuff for all CA's
  docker exec ${INTERACTIVE} cli  /bin/bash -c ". ./organizations/fabric-ca/registerEnroll.sh && createOrgs"
  # Spawn all CA containers
  docker-compose -f $COMPOSE_FILE_CA up -d > log.txt 2>&1 --remove-orphans
  cat log.txt
  # Register peer0 user "org admin" "peer0 msp" "certificates"
  docker exec ${INTERACTIVE} ca_centralgovernment /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createCentralgovernment"
  docker exec ${INTERACTIVE} ca_stategovernmentfps /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createStategovernmentfps"
  docker exec ${INTERACTIVE} ca_stategovernmentdepot /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createStategovernmentdepot"
  docker exec ${INTERACTIVE} ca_other /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createOther"
  docker exec ${INTERACTIVE} ca_orderer /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createOrderer"
}

function networkDown {
  pwd
  ls organizations
  rm log.txt
  rm -r ./channel-artifacts
  rm -r ./organizations/ordererOrganizations
  rm -r ./organizations/peerOrganizations
  rm -r ./organizations/fabric-ca/ordererOrg
  rm -r ./organizations/fabric-ca/centralgovernment
  rm -r ./organizations/fabric-ca/stategovernmentdepot
  rm -r ./organizations/fabric-ca/stategovernmentfps  
  docker-compose -f $CLI_FILE down > log.txt 2>&1 --remove-orphans
  cat log.txt
  docker-compose -f $COMPOSE_FILE_CA down > log.txt 2>&1 --remove-orphans
  cat log.txt

  # TODO: Add commands to remove the generated files
}

if [ "$1" == "up" ]; then
  networkUp
elif [ "$1" == "down" ]; then
  networkDown
fi

# TODO: Add .gitignore to remove all generated fiels from git