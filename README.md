# tpds-hyperledger
TPDS Supply chain proof of concept in Hyperledger Fabric. Network with four orgs and a specific chaincode exposed as rest API

# Installation instructions

1. Install Hyperledger fabric dependencies:
https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html

2. Donwload fabric binaries and samples:
`curl -sSL http://bit.ly/2ysbOFE | bash -s`

3. Download the tpds:
`git clone https://github.com/gvaibhav1734/tpds-hyperledger`

4. Go to tpds folder:
`cd tpds-hyperledger`

5. Go to network folder
`cd network`

6. Set PATH environment variable to include fabric-samples/bin from the repo cloned in step 2.

7. Start the network
`./start.sh`



# Generate identities
1. Go to application folder (from the tpds-hyperledger folder)
`cd application`

2. Run createIdentities.js
`node createIdentities.js`

3. If you stop and restart the fabric network, you will need to regenerate the identities. Delete existing wallet folders, change user names under all orgs and run the file according to step 2


# Test the chaincode
1. Go to application folder (from the tpds-hyperledger folder)
`cd application`

2. If you modified the name of user identity generated above, correspondingly modify the user name in the testApp.js file.

3. Run test file
`node testApp.js`

# Run App
1. Go to application folder (from the tpds-hyperledger folder)
`cd application`

2. If you modified the name of user identity generated above, correspondingly modify the user name in the server.js file.

3. `cd tpds-app`

3. Run app
`npm run dev`

# Stop the network
1. Go to network folder (from the tpds-hyperledger folder)
`cd network`

2. Stop the network
`./network.sh down`


# API Doc
**createAsset**
----
  Add new food grain asset to the blockchain network (owner must always be "Central Government")

* **URL**

  `/tpds/createAsset`

* **Method:**
  
	`POST` 

* **Data Params**

```
  "ID":string,
  "Quantity":number,
  "Owner":string
 ``` 

* **Success Response:**
  
``` 
{	
  "status":"OK - Transaction has been submitted"
} 
```
 
* **Sample Call:**

 ``` 
curl --request POST --url http://localhost:3000/tpds/createAsset --header 'content-type: application/json' --data '{	"ID":1001, "Quantity":50, "Owner":"Central Government" }' 
 ```
            
**getAsset**
----
  Get food grain asset from the blockchain with the actual status

* **URL**

  `/tpds/getAsset/:id`

* **Method:**
  
	`GET` 

* **URL Params**
    `"id":string`

* **Success Response:**
  
 ``` 
 {
    "result": {
        "ID": integer
        "Quantity": number
        "Owner": string
        "PrevOwners": string array
        "State": integer
        "SendTime": number
        "ExpectedTime": number
        "ExpectedReceiver": string
    } 
 }
 ```
 
* **Sample Call:**

``` 
curl --request GET --url 'http://localhost:3000/tpds/getAsset/1001' --header 'content-type: application/json'
```

**sendAsset**
----
  Send food grain asset to the next entity in supply chain

* **URL**

  `/tpds/sendAsset`

* **Method:**
  
	`POST` 

* **Data Params**

```
  "ID":string,
  "From":string,
  "To":string
 ``` 

* **Success Response:**
  
``` 
{	
  "status":"OK - Transaction has been submitted"
} 
```
 
* **Sample Call:**

 ``` 
curl --request POST --url http://localhost:3000/tpds/sendAsset --header 'content-type: application/json' --data '{	"ID":1001, "From":"Central Government", "To":"State Government Depot" }' 
 ```

 **receiveAsset**
----
  Receive food grain asset by the next entity in supply chain

* **URL**

  `/tpds/receiveAsset`

* **Method:**
  
	`POST` 

* **Data Params**

```
  "ID":string,
  "From":string,
  "To":string
 ``` 

* **Success Response:**
  
``` 
{	
  "status":"OK - Transaction has been submitted"
} 
```
 
* **Sample Call:**

 ``` 
curl --request POST --url http://localhost:3000/tpds/receiveAsset --header 'content-type: application/json' --data '{	"ID":1001, "From":"Central Government", "To":"State Government Depot" }' 
 ```

 **deleteAsset**
----
  Delete a food grain asset from the blockchain
* **URL**

  `/tpds/deleteAsset`

* **Method:**
  
	`POST` 

* **Data Params**

```
  "ID":string
``` 

* **Success Response:**
  
``` 
{	
  "status":"OK - Transaction has been submitted"
} 
```
 
* **Sample Call:**

 ``` 
curl --request POST --url http://localhost:3000/tpds/deleteAsset --header 'content-type: application/json' --data '{	"ID":1001 }' 
 ```
 
 **getAllAssets**
----
  Get all food grain assets from the blockchain with the actual status

* **URL**

  `/tpds/getAllAssets`

* **Method:**
  
	`GET` 

* **Success Response:**
  
 ``` 
 [{
    "result": {
        "ID": integer
        "Quantity": number
        "Owner": string
        "PrevOwners": string array
        "State": integer
        "SendTime": number
        "ExpectedTime": number
        "ExpectedReceiver": string
    } 
 }, ... ]
 ```
 
* **Sample Call:**

``` 
curl --request GET --url 'http://localhost:3000/tpds/getAllAssets' --header 'content-type: application/json'
```
 
 **checkLeakage**
----
  Checks all food grain assets in the blockchain for a possibility of leakage

* **URL**

  `/tpds/checkLeakage`

* **Method:**
  
	`GET` 

* **Success Response:**
  
 ``` 
 [{
    "result": {
        "ID": integer
        "Quantity": number
        "Owner": string
        "PrevOwners": string array
        "State": integer
        "SendTime": number
        "ExpectedTime": number
        "ExpectedReceiver": string
    } 
 }, ... ]
 ```
 
* **Sample Call:**

``` 
curl --request GET --url 'http://localhost:3000/tpds/checkLeakage' --header 'content-type: application/json'
```


## Note

The following paths have been hardcoded and must be changed as needed:
 - Paths in application/AppUtil.js 
 - Paths in all application/tpds-app/pages/api/* js files