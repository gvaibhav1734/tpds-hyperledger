# tpds-hyperledger
TPDS Supply chain proof of concept in Hyperledger Fabric. Network with four orgs and a specific chaincode exposed as rest API

# Installation instructions

1. Install Hyperledger fabric dependencies:
https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html

2. Donwload fabric binaries and samples:
`curl -sSL http://bit.ly/2ysbOFE | bash -s 1.4.3`

3. Go to fabric samples:
`cd fabric-samples`

4. Download the template:
`git clone https://github.com/gvaibhav1734/tpds-hyperledger`

6. Go to 
`tpds-hyperledger`

5. Install node-js dependencies
`./network.sh install`



# Start the network
1. Generate the crypto material and start the network
`./network.sh start`
This will create the crypto material for all the orgs, start the network and register it's admins and users. Then will start the API at localhost:3000


# Re-start the API server
`npm start`

# Stop the network
`./network.sh stop`


# API Doc
**CreateFoodGrainAsset**
----
  Add new food grain asset to the blockchain network

* **URL**

  `/api/createFoodGrainAsset`

* **Method:**
  
	`POST` 

* **Data Params**

```
  "id":integer,
  "quantity":string,
 ``` 

* **Success Response:**
  
``` 
{	
  "status":"OK - Transaction has been submitted",
  "txid":"7f485a8c3a3c7f982aed76e3b20a0ad0fb4cbf174fbeabc792969a30a3383499"
} 
```
 
* **Sample Call:**

 ``` 
 curl --request POST \
  --url http://localhost:3000/api/createFoodGrainAsset \
  --header 'content-type: application/json' \
  --data '{
			"id":1001,
			"quantity":"50",
		   }' 
 ```
            
**getFoodGrainAsset**
----
  Get Tuna from the blockchain with the actual status

* **URL**

  `/api/getFoodGrainAsset/:id`

* **Method:**
  
	`GET` 

* **URL Params**
    `"id":integer`

* **Success Response:**
  
 ``` 
 {
    "result": {
        "id": integer
        "owner": string
        "prev_owners": string array
        "state": integer
    } 
 }
 ```
 
* **Sample Call:**

``` 
curl --request GET \
  --url 'http://localhost:3000/api/getFoodGrainAsset/<TunaId>' \
  --header 'content-type: application/json' \ 
```


**transferFoodGrainAsset**
----
  Changes the owner and prev_owners for the specified foood grain asset id when a transfer happens

* **URL**

  `/api/getTuna/transferFoodGrainAsset`

* **Method:**
  
	`POST` 

* **Data Params**
``` 
"id":integer,
"from":string,
"to":string
``` 

* **Success Response:**
  
 ``` 
{	
	status":"OK - Transaction has been submitted",
	"txid":"7f485a8c3a3c7f982aed76e3b20a0ad0fb4cbf174fbeabc792969a30a3383499"
}
 ```
 
* **Sample Call:**

``` 
curl --request POST \
  --url http://localhost:3000/api/transferFoodGrainAsset \
  --header 'content-type: application/json' \
  --data '{
            "id":1001,
            "from":"Central Government",
            "to":"State Government Depot"
			}'
```