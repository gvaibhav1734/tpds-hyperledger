#!/bin/bash

echo "Installing chaincode for Central Government..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 centralgovernment CentralGovernmentMSP 7051 1.0
echo "Installing chaincode for State Government Depot..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 stategovernmentdepot StateGovernmentDepotMSP 9051 1.0
echo "Installing chaincode for State Government FPS..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 stategovernmentfps StateGovernmentFPSMSP 10051 1.0
echo "Installing chaincode for Other..."
docker exec -it cli ./scripts/install-cc/install-peer.sh peer0 other OtherMSP 11051 1.0
echo "Instanciating the chaincode..."
docker exec -it cli ./scripts/install-cc/instanciate.sh 
