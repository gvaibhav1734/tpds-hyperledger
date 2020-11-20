#!/bin/bash
node src/enrollAdmin.js fps
node src/enrollAdmin.js centralgovernment
node src/enrollAdmin.js depots
node src/enrollAdmin.js fps

node src/registerUser.js fps
node src/registerUser.js centralgovernment
node src/registerUser.js depots
node src/registerUser.js fps

echo "***********************************"
echo "       Starting API server         "
echo "***********************************"
npm start