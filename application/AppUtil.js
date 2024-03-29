/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const fs = require('fs');
const path = require('path');

exports.buildCCPcentralgovernment = () => {
	// load the common connection configuration file
	const ccpPath = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/network/organizations/peerOrganizations/centralgovernment.example.com/connection-centralgovernment.json';// path.resolve(__dirname, '..', 'network', 'organizations', 'peerOrganizations', 'centralgovernment.example.com', 'connection-centralgovernment.json');
	// console.log(ccpPath);
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildCCPstategovernmentdepot = () => {
	// load the common connection configuration file
	const ccpPath = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/network/organizations/peerOrganizations/stategovernmentdepot.example.com/connection-stategovernmentdepot.json' ;//path.resolve(__dirname, '..', 'network', 'organizations', 'peerOrganizations', 'stategovernmentdepot.example.com', 'connection-stategovernmentdepot.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildCCPstatelevelfps = () => {
	// load the common connection configuration file
	const ccpPath = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/network/organizations/peerOrganizations/statelevelfps.example.com/connection-statelevelfps.json' ;// path.resolve(__dirname, '..', 'network', 'organizations', 'peerOrganizations', 'statelevelfps.example.com', 'connection-statelevelfps.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildCCPother = () => {
	// load the common connection configuration file
	const ccpPath = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/network/organizations/peerOrganizations/other.example.com/connection-other.json' ;// path.resolve(__dirname, '..', 'network', 'organizations', 'peerOrganizations', 'other.example.com', 'connection-other.json');
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildWallet = async (Wallets, walletPath) => {
	// Create a new  wallet : Note that wallet is for managing identities.
	let wallet;
	if (walletPath) {
		wallet = await Wallets.newFileSystemWallet(walletPath);
		console.log(`Built a file system wallet at ${walletPath}`);
	} else {
		wallet = await Wallets.newInMemoryWallet();
		console.log('Built an in memory wallet');
	}

	return wallet;
};

exports.prettyJSONString = (inputString) => {
	if (inputString) {
		 return JSON.stringify(JSON.parse(inputString), null, 2);
	}
	else {
		 return inputString;
	}
}
