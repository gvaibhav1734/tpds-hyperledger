'use strict';

const { Contract, Context } = require('fabric-contract-api');

const ownerStates = {
	CENTRALGOVERNMENT: 1,
	STATEGOVERNMENTDEPOT: 2,
	STATELEVELFPS: 3,
	OTHER: 4
};

const assetStates = {
	CREATED: 1,
	INTRANSIT: 2,
	DELIVERED: 3
};

class TPDSAsset {

    constructor(id, owner, quantity) {
        this.id = id;
        this.owner = owner;
        this.quantity = quantity;
        this.prev_owners = [];
        this.state = assetStates.CREATED;        
    }

}

class User {
	constructor(id, usertype) {
		this.id = id;
		this.owns = [];
		this.quantity = 0;
		this.type = usertype;
	}
}

class SupplyChainContext extends Context {
    constructor() {
        // super();
        this.assetID = 0;
        this.userID = 0;
		this.assetList = [];
    }
    
    updateAssetID() {
    	this.assetID = this.assetID + 1;
    }
    
    updateUserID() {
    	this.userID = this.userID + 1;
    }
    
    getAssetID() {
    	return this.assetID;
    }
    
    getUserID() {
    	return this.userID;
    }
}

class SupplyChain extends Contract {

	createContext() {
        return new SupplyChainContext();
    }

	async createAsset(ctx, asset) {
	  console.info('============= START : Add asset ===========');
	  await ctx.stub.putState(JSON.parse(asset).id.toString(), Buffer.from(asset));
	  ctx.assetList.push(JSON.parse(asset).id.toString());
	  console.info('============= END : Add asset ===========');
	  return ctx.stub.getTxID();
	}

	async changeOwner(ctx, id, from, to) {
	  console.info('============= START : Transfer and Change Owner ===========');
	  const keyAsBytes = await ctx.stub.getState(id); 
	  if (!keyAsBytes || keyAsBytes.length === 0) {
		throw new Error(`${id} does not exist`);
	  }
	  let key = JSON.parse(keyAsBytes.toString());
	  if (key.owner != from) {
		throw new Error(`${from} cannot make this transfer`);
	  }
	  key.owner = to;
	  key.prev_owners.push(from);
	  key.state = 2;
	  await ctx.stub.putState(id, Buffer.from(JSON.stringify(key)));
	  console.info('============= END : Transfer and Change Owner ===========');
	  return ctx.stub.getTxID();
	}
	
	async queryAsset(ctx, assetId) {
		console.info('============= START : Query asset ===========');
		const assetAsBytes = await ctx.stub.getState(assetId); 
		if (!assetAsBytes || assetAsBytes.length === 0) {
		  throw new Error(`${assetId} does not exist`);
		}
		console.log(assetAsBytes.toString());
		console.info('============= END : Query asset ===========');
		return assetAsBytes.toString();
	}

	// async queryAllAssets(ctx) {
	// 	console.info('============= START : Query all assets ===========');
	// 	var ans = {"data": [1,2,3]};
	// 	// var assetStrings = [];
	// 	// assetStrings.push("test before");
	// 	// for(var id in ctx.assetList) {
	// 	// for(var i = 0; i < 3; i++) {
	// 		// const assetAsBytes = await ctx.stub.getState(id);
	// 		// assetStrings.push(assetAsBytes.toString());
	// 		// assetStrings.push("test");
	// 		// console.log(assetAsBytes.toString());
	// 	// }
	// 	// assetStrings.push("test after");
	// 	console.info('============= END : Query all assets ===========');
	// 	// return assetStrings;
	// 	return JSON.stringify(ans);
	// }

	// async addAsset(ctx, asset) {
	//   console.info('============= START : Add asset ===========');
	//   await ctx.stub.putState(JSON.parse(asset).id.toString(), Buffer.from(asset));
	//   console.info('============= END : Add asset ===========');
	//   return ctx.stub.getTxID()
	// }

	// async queryAsset(ctx, assetId) {
	//   console.info('============= START : Query asset ===========');
	//   const assetAsBytes = await ctx.stub.getState(assetId); 
	//   if (!assetAsBytes || assetAsBytes.length === 0) {
	// 	throw new Error(`${assetId} does not exist`);
	//   }
	//   console.log(assetAsBytes.toString());
	//   console.info('============= END : Query asset ===========');
	//   return assetAsBytes.toString();
	// }
	  
	// async setPosition(ctx, id, latitude, longitude) {
	//   console.info('============= START : Set position ===========');
	//   const keyAsBytes = await ctx.stub.getState(id); 
	//   if (!keyAsBytes || keyAsBytes.length === 0) {
	// 	throw new Error(`${id} does not exist`);
	//   }
	//   let key = JSON.parse(keyAsBytes.toString());
	//   key.latitude = latitude;
	//   key.longitude = longitude;
	//   await ctx.stub.putState(id, Buffer.from(JSON.stringify(key)));
	//   console.info('============= END : Set position ===========');
	//   return ctx.stub.getTxID();
	// }

	// async getHistory(ctx, id) {
	//   console.info('============= START : Query History ===========');
	//   let iterator = await ctx.stub.getHistoryForKey(id);
	//   let result = [];
	//   let res = await iterator.next();
	//   while (!res.done) {
	// 	if (res.value) {
	// 	  console.info(`found state update with value: ${res.value.value.toString('utf8')}`);
	// 	  const obj = JSON.parse(res.value.value.toString('utf8'));
	// 	  result.push(obj);
	// 	}
	// 	res = await iterator.next();
	//   }
	//   await iterator.close();
	//   console.info('============= END : Query History ===========');
	//   return result;  
	// }


}

module.exports = SupplyChain;
