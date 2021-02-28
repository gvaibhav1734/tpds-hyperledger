#!/bin/bash
node src/enrollAdmin.js centralgovernment
node src/enrollAdmin.js stategovernmentdepot
node src/enrollAdmin.js stategovernmentfps
node src/enrollAdmin.js other

node src/registerUser.js centralgovernment
node src/registerUser.js stategovernmentdepot
node src/registerUser.js stategovernmentfps
node src/registerUser.js other

echo "***********************************"
echo "       Starting API server         "
echo "***********************************"
npm start
