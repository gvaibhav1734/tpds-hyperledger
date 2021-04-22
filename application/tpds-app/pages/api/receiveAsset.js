const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const { buildCCPstategovernmentdepot, buildCCPstatelevelfps, buildCCPother, buildWallet } = require('../../../AppUtil');


// TODO : Update variables as needed
const channelName = 'channel1';
const chaincodeName = 'tpds';
const walletPath_sgd = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/application/wallet-sgd';
const walletPath_slf = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/application/wallet-slf';
const walletPath_o = '/home/arpitha/IT/MajorProject/try3/tpds-hyperledger/application/wallet-o';
const UserId_sgd = 'sgduser2';
const UserId_slf = 'slfuser2';
const UserId_o = 'ouser2';

export default async function handler(req, res) {
    try {
        var walletPath;
        var UserId;
        var ccp;

        if (req.body.From == 'State Government Depot') {
            walletPath = walletPath_sgd;
            UserId = UserId_sgd;
            ccp = buildCCPstategovernmentdepot();
        } else if (req.body.From == 'State Level FPS') {
            walletPath = walletPath_slf;
            UserId = UserId_slf;
            ccp = buildCCPstatelevelfps();
        } else {
            walletPath = walletPath_o;
            UserId = UserId_o;
            ccp = buildCCPother();
        }

        const wallet = await buildWallet(Wallets, walletPath);
        const gateway = new Gateway();
        var result;
        await gateway.connect(ccp, {
            wallet,
            identity: UserId,
            discovery: { enabled: true, asLocalhost: true }
        });
        const network = await gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);
        result = await contract.submitTransaction('ReceiveAsset', req.body.ID, req.body.From, req.body.To);
        console.log(`result: ${result}`);
        res.status(200).json({ status: 'OK - Transaction has been submitted' });
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