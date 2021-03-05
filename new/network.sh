export IMAGE_TAG=2.3
export IMAGE_TAG_CA=1.4.9
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
CLI_FILE=docker/docker-compose-cli.yaml
INTERACTIVE=''

function networkUp {
  rm log.txt
  docker-compose -f $CLI_FILE up -d > log.txt 2>&1 --remove-orphans
  cat log.txt
  docker exec ${INTERACTIVE} cli  /bin/bash -c ". ./organizations/fabric-ca/registerEnroll.sh && createOrgs"
  docker-compose -f $COMPOSE_FILE_CA up -d > log.txt 2>&1 --remove-orphans
  cat log.txt
  docker exec ${INTERACTIVE} ca_centralgovernment /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createCentralgovernment"
  docker exec ${INTERACTIVE} ca_stategovernmentfps /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createStategovernmentfps"
  docker exec ${INTERACTIVE} ca_stategovernmentdepot /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createStategovernmentdepot"
  docker exec ${INTERACTIVE} ca_other /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createOther"
  docker exec ${INTERACTIVE} ca_orderer /bin/bash -c ". organizations/fabric-ca/registerEnroll.sh && createOrderer"
}

function networkDown {
  rm log.txt
  docker-compose -f $CLI_FILE down > log.txt 2>&1 --remove-orphans
  cat log.txt
  docker-compose -f $COMPOSE_FILE_CA down > log.txt 2>&1 --remove-orphans
  cat log.txt
}

if [ "$1" == "up" ]; then
  networkUp
elif [ "$1" == "down" ]; then
  networkDown
fi