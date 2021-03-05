export IMAGE_TAG=2.3
export IMAGE_TAG_CA=1.4.9
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
CLI_FILE=docker/docker-compose-cli.yaml

docker-compose -f $COMPOSE_FILE_CA up -d > log.txt 2>&1 --remove-orphans
docker-compose -f $CLI_FILE up -d > log.txt 2>&1 --remove-orphans
cat log.txt
docker exec -it cli ./organizations/fabric-ca/registerEnroll.sh
docker exec -it ca_centralgovernment ./organizations/fabric-ca/registerEnroll.sh createcentralgovernment