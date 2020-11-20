#!/bin/bash
export IMAGE_TAG=1.4.3

echo "Creating containers... "

# TODO This approach is hacky; instead, identify where hyperledger/fabric-ccenv is pulled and update the tag to 1.4.3
docker pull hyperledger/fabric-ccenv:1.4.3
docker tag hyperledger/fabric-ccenv:1.4.3 hyperledger/fabric-ccenv:latest

docker-compose -f ./supply-network/docker-compose-cli.yaml up -d
echo 
echo "Containers started" 
echo 
docker ps

docker exec -it cli ./scripts/channel/createChannel.sh

echo "Joining Depots to channel..."
docker exec -it cli ./scripts/channel/join-peer.sh peer0 depots DepotsMSP 10051 1.0
echo "Joining CentralGovernment to channel..."
docker exec -it cli ./scripts/channel/join-peer.sh peer0 centralgovernment CentralGovernmentMSP 9051 1.0
echo "Joining FPS to channel..." 
docker exec -it cli ./scripts/channel/join-peer.sh peer0 fps FPSMSP 11051 1.0
