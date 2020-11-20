#!/bin/bash
echo $1
echo "Installing chaincode for fps..."
docker exec -it cli ./scripts/install-cc/install-fps.sh $1
echo "Installing chaincode for centralgovernment..."
docker exec -it cli ./scripts/install-cc/install-centralgovernment.sh $1
echo "Installing chaincode for depots..."
docker exec -it cli ./scripts/install-cc/install-depots.sh $1
echo "Installing chaincode for fps..."
docker exec -it cli ./scripts/install-cc/install-fps.sh $1
echo "Instanciating the chaincode..."
docker exec -it cli ./scripts/install-cc/upgrade.sh $1