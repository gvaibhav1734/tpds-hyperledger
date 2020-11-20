#!/bin/bash

echo "Installing chaincode for fps..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 fps FpsMSP 7051 1.0
echo "Installing chaincode for centralgovernment..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 centralgovernment CentralGovernmentMSP 9051 1.0
echo "Installing chaincode for depots..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 depots DepotsMSP 10051 1.0
echo "Installing chaincode for fps..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 fps FPSMSP 11051 1.0
echo "Instanciating the chaincode..."
docker exec -it cli ./scripts/install-cc/instanciate.sh 