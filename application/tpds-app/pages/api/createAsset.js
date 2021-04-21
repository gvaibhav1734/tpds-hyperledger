const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const { buildCCPcentralgovernment, buildWallet } = require('../../../AppUtil');


// TODO : Update variables as needed
const channelName = 'channel1';
const chaincodeName = 'tpds';
const walletPath_cg = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/application/wallet-cg';
const UserId_cg = 'cguser2';

export default async function handler(req, res) {
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
        result = await contract.submitTransaction('CreateAsset', req.body.ID, req.body.Quantity, 'Central Government');
        console.log(`result: ${result}`);
        res.status(200).json({ result: JSON.parse(result.toString()), status: 'OK - Transaction has been submitted' });
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        res.status(500).json({ error: error });
    }
}

export const config = {
    api: {
      bodyParser: {
        sizeLimit: '1mb',
      },
    },
}