/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class AssetTransfer extends Contract {

    async InitLedger(ctx) {
        const assets = [
            // {
            //     ID: '1001',
            //     Quantity: 50,
            //     Owner: 'Central Government',
            //     PrevOwners: [],
            //     State: 1,
            //     SendTime: 0,
            //     ExpectedTime: 0,
            //     ExpectedReceiver: ''
            // }
        ];

        for (const asset of assets) {
            asset.docType = 'asset';
            await ctx.stub.putState(asset.ID, Buffer.from(JSON.stringify(asset)));
            console.info(`Asset ${asset.ID} initialized`);
        }
    }

    // CreateAsset issues a new asset to the world state with given details.
    async CreateAsset(ctx, id, quantity, owner) {
        if (owner != 'Central Government') {
            throw new Error(`${owner} cannot create an asset`);
        }
        const asset = {
            ID: id,
            Quantity: quantity,
            Owner: owner,
            PrevOwners: [],
            State: 1,
            SendTime: '',
            ExpectedTime: '',
            ExpectedReceiver: ''
        };
        ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
        return JSON.stringify(asset);
    }

    // ReadAsset returns the asset stored in the world state with given id.
    async ReadAsset(ctx, id) {
        const assetJSON = await ctx.stub.getState(id); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return assetJSON.toString();
    }

    // SendAsset updates the asset with given id in the world state.
    async SendAsset(ctx, id, from, to) {
        const assetString = await this.ReadAsset(ctx, id);
        const asset = JSON.parse(assetString);

        if (from != asset.Owner) {
            throw new Error(`${from} cannot execute this transaction`);
        }

        var timeDiff = 300;
        var sendTime = Math.floor(Date.now() / 1000);
        var expectedTime = sendTime + timeDiff;

        asset.SendTime = sendTime;
        asset.ExpectedTime = expectedTime;
        asset.State = 2;
        asset.ExpectedReceiver = to;

        return ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    }

    // ReceiveAsset updates the asset with given id in the world state.
    async ReceiveAsset(ctx, id, from, to) {
        const assetString = await this.ReadAsset(ctx, id);
        const asset = JSON.parse(assetString);

        var receivedTime = Math.floor(Date.now() / 1000); 

        var allowedDelay = 100;
        if ((receivedTime - asset.ExpectedTime) > allowedDelay) {
            throw new Error(`Verify transaction, delay in receiving asset`);
        }

        if (from != asset.Owner || to != asset.ExpectedReceiver) {
            throw new Error(`${to} cannot execute this transaction`);
        }

        asset.SendTime = '';
        asset.ExpectedTime = '';
        asset.State = 1;
        asset.ExpectedReceiver = '';

        asset.Owner = to;
        asset.PrevOwners.push(from);

        return ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    }

    // DeleteAsset deletes an given asset from the world state.
    async DeleteAsset(ctx, id) {
        const exists = await this.AssetExists(ctx, id);
        if (!exists) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return ctx.stub.deleteState(id);
    }

    // AssetExists returns true when asset with given ID exists in world state.
    async AssetExists(ctx, id) {
        const assetJSON = await ctx.stub.getState(id);
        return assetJSON && assetJSON.length > 0;
    }

    // GetAllAssets returns all assets found in the world state.
    async GetAllAssets(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: result.value.key, Record: record });
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }

    // VerifyLeakage iterates through all assets found in the world state checking for leakage.
    async VerifyLeakage(ctx) {
        const leakageResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            if (record.State == 2) {
                var currentTime = Math.floor(Date.now() / 1000); 
                var allowedDelay = 100;
                if ((currentTime - record.ExpectedTime) > allowedDelay) {
                    leakageResults.push({ Key: result.value.key, Record: record });
                }
            }
            result = await iterator.next();
        }
        return JSON.stringify(leakageResults);
    }
}

module.exports = AssetTransfer;
