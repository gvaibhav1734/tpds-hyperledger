export IMAGE_TAG=2.3
export IMAGE_TAG_CA=1.4.9
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
COMPOSE_FILE_NET=docker/docker-compose-net.yaml
CLI_FILE=docker/docker-compose-cli.yaml
INTERACTIVE=''

function networkUp {
  export IMAGE_TAG=2.3
  export IMAGE_TAG_CA=1.4.9
  rm log.txt
  # Spawn cli container to generate crypt stuff for CA's
  docker-compose -f $CLI_FILE up -d > log.txt 2>&1
  cat log.txt
  echo
  echo
  echo
  echo
  # THe function which generates all crypt stuff for all CA's
  docker exec ${INTERACTIVE} cli  /bin/bash -c ". ./scripts/registerEnroll.sh && createOrgs"
  echo "done"
  # Spawn all CA containers
  docker-compose -f $COMPOSE_FILE_CA up -d > log.txt 2>&1
  cat log.txt
  # Register peer0 user "org admin" "peer0 msp" "certificates"
  docker exec ${INTERACTIVE} ca_centralgovernment /bin/bash -c ". scripts/registerEnroll.sh && createCentralgovernment"
  docker exec ${INTERACTIVE} ca_stategovernmentfps /bin/bash -c ". scripts/registerEnroll.sh && createStategovernmentfps"
  docker exec ${INTERACTIVE} ca_stategovernmentdepot /bin/bash -c ". scripts/registerEnroll.sh && createStategovernmentdepot"
  docker exec ${INTERACTIVE} ca_other /bin/bash -c ". scripts/registerEnroll.sh && createOther"
  docker exec ${INTERACTIVE} ca_orderer /bin/bash -c ". scripts/registerEnroll.sh && createOrderer"
  docker-compose -f $COMPOSE_FILE_NET up -d > log.txt 2>&1
}

function networkDown {
  pwd
  ls organizations
  rm log.txt
  rm -r ./channel-artifacts 2> /dev/null || true
  rm -r ./organizations/ordererOrganizations 2> /dev/null || true
  rm -r ./organizations/peerOrganizations 2> /dev/null || true
  rm -r ./organizations/fabric-ca/ordererOrg 2> /dev/null || true
  rm -r ./organizations/fabric-ca/centralgovernment 2> /dev/null || true
  rm -r ./organizations/fabric-ca/stategovernmentdepot 2> /dev/null || true
  rm -r ./organizations/fabric-ca/stategovernmentfps 2> /dev/null || truee
  rm -r ./organizations/fabric-ca/ca_other 2> /dev/null || truee
  docker-compose -f $CLI_FILE down > log.txt 2>&1 --remove-orphans
  cat log.txt
  docker-compose -f $COMPOSE_FILE_CA down > log.txt 2>&1 --remove-orphans
  docker volume prune -f
  docker network prune -f
  cat log.txt

  # TODO: Add commands to remove the generated files
}

if [ "$1" == "up" ]; then
  networkUp
elif [ "$1" == "down" ]; then
  networkDown
fi

# TODO: Add .gitignore to remove all generated fiels from git