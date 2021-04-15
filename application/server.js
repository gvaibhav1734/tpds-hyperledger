/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('./CAUtil.js');
const { buildCCPcentralgovernment, buildCCPstategovernmentdepot, buildCCPstatelevelfps, buildCCPother, buildWallet } = require('./AppUtil.js');

// TODO : Update variables as needed
const channelName = 'mychannel';
const chaincodeName = 'tpds';
const msp_cg = 'centralgovernmentMSP';
const msp_sgd = 'stategovernmentdepotMSP';
const msp_slf = 'statelevelfpsMSP';
const msp_o = 'otherMSP';
const walletPath_cg = path.join(__dirname, 'wallet-cg');
const walletPath_sgd = path.join(__dirname, 'wallet-sgd');
const walletPath_slf = path.join(__dirname, 'wallet-slf');
const walletPath_o = path.join(__dirname, 'wallet-o');
const UserId_cg = 'cguser2';
const UserId_sgd = 'sgduser2';
const UserId_slf = 'slfuser2';
const UserId_o = 'ouser2';

const express = require('express');
const bodyParser = require('body-parser');
const app = express();
// app.use(express.urlencoded({
//     extended: true
// }));

var jsonParser = bodyParser.json();
var urlencodedParser = bodyParser.urlencoded({ extended: true });

app.use(jsonParser);
app.use(urlencodedParser);


function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}

app.get('/tpds/test', async function (req, res) {
    try {
        res.json({result:'hello world tpds!'});
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        res.status(500).json({
        error: error
        });
    }
});

app.post('/tpds/createAsset', async function (req, res) {

    try {
        const ccp = buildCCPcentralgovernment();
        const wallet = await buildWallet(Wallets, walletPath_cg);
        const gateway = new Gateway();
        var result;
        await gateway.connect(ccp, {
            wallet,
            identity: UserId_cg,
            discovery: { enabled: true, asLocalhost: true }
        });
        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);
        result = await contract.submitTransaction('CreateAsset', req.body.ID, req.body.Quantity, req.body.Owner);
        console.log(`result: ${result}`);
        res.json({
            status: 'OK - Transaction has been submitted',
        });
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        res.status(500).json({
        error: error
        });
    }
});

app.get('/tpds/getAsset/:id', async function (req, res) {
    try {
        const ccp = buildCCPcentralgovernment();
        const wallet = await buildWallet(Wallets, walletPath_cg);
        const gateway = new Gateway();
        var result;
        await gateway.connect(ccp, {
            wallet,
            identity: UserId_cg,
            discovery: { enabled: true, asLocalhost: true }
        });
        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);
        result = await contract.evaluateTransaction('ReadAsset', req.params.id.toString());
        let response = JSON.parse(result.toString());
        res.json({result:response});
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        res.status(500).json({
            error: error
        });
    }
});
  


app.listen(3000, ()=>{
    console.log("***********************************");
    console.log("API server listening at localhost:3000");
    console.log("***********************************");
  });