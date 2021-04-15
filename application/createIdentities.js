
/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('./CAUtil.js');
const { buildCCPcentralgovernment, buildCCPstategovernmentdepot, buildCCPstatelevelfps, buildCCPother, buildWallet } = require('./AppUtil.js');

// TODO : Update variables as needed
const channelName = 'mychannel';
const chaincodeName = 'tpds';
const walletPath_cg = path.join(__dirname, 'wallet-cg');
const walletPath_sgd = path.join(__dirname, 'wallet-sgd');
const walletPath_slf = path.join(__dirname, 'wallet-slf');
const walletPath_o = path.join(__dirname, 'wallet-o');

function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}

async function main() {
	try {
		// build an in memory object with the network configuration (also known as a connection profile)
		const ccp1 = buildCCPcentralgovernment();
		// build an instance of the fabric ca services client based on
		// the information in the network configuration
		const caClient1 = buildCAClient(FabricCAServices, ccp1, 'ca.centralgovernment.example.com');
		// setup the wallet to hold the credentials of the application user
		const wallet1 = await buildWallet(Wallets, walletPath_cg);
		// in a real application this would be done on an administrative flow, and only once
		await enrollAdmin(caClient1, wallet1, 'centralgovernmentMSP');
		// in a real application this would be done only when a new user was required to be added
		// and would be part of an administrative flow
		await registerAndEnrollUser(caClient1, wallet1, 'centralgovernmentMSP', 'cguser2', 'centralgovernment.department1');

        // build an in memory object with the network configuration (also known as a connection profile)
		const ccp2 = buildCCPstategovernmentdepot();
		// build an instance of the fabric ca services client based on
		// the information in the network configuration
		const caClient2 = buildCAClient(FabricCAServices, ccp2, 'ca.stategovernmentdepot.example.com');
		// setup the wallet to hold the credentials of the application user
		const wallet2 = await buildWallet(Wallets, walletPath_sgd);
		// in a real application this would be done on an administrative flow, and only once
		await enrollAdmin(caClient2, wallet2, 'stategovernmentdepotMSP');
		// in a real application this would be done only when a new user was required to be added
		// and would be part of an administrative flow
		await registerAndEnrollUser(caClient2, wallet2, 'stategovernmentdepotMSP', 'sgduser2', 'stategovernmentdepot.department1');

        // build an in memory object with the network configuration (also known as a connection profile)
		const ccp3 = buildCCPstatelevelfps();
		// build an instance of the fabric ca services client based on
		// the information in the network configuration
		const caClient3 = buildCAClient(FabricCAServices, ccp3, 'ca.statelevelfps.example.com');
		// setup the wallet to hold the credentials of the application user
		const wallet3 = await buildWallet(Wallets, walletPath_slf);
		// in a real application this would be done on an administrative flow, and only once
		await enrollAdmin(caClient3, wallet3, 'statelevelfpsMSP');
		// in a real application this would be done only when a new user was required to be added
		// and would be part of an administrative flow
		await registerAndEnrollUser(caClient3, wallet3, 'statelevelfpsMSP', 'slfuser2', 'statelevelfps.department1');

        // build an in memory object with the network configuration (also known as a connection profile)
		const ccp4 = buildCCPother();
		// build an instance of the fabric ca services client based on
		// the information in the network configuration
		const caClient4 = buildCAClient(FabricCAServices, ccp4, 'ca.other.example.com');
		// setup the wallet to hold the credentials of the application user
		const wallet4 = await buildWallet(Wallets, walletPath_o);
		// in a real application this would be done on an administrative flow, and only once
		await enrollAdmin(caClient4, wallet4, 'otherMSP');
		// in a real application this would be done only when a new user was required to be added
		// and would be part of an administrative flow
		await registerAndEnrollUser(caClient4, wallet4, 'otherMSP', 'ouser2', 'other.department1');

	} catch (error) {
		console.error(`******** FAILED to create all identities: ${error}`);
	}
}

main();