# MNCT
Meraki Network Configuration Tool

Special thanks to some hard work from https://github.com/sanderkl.

# Getting Started
Download the entire repository and start by launching MerakiNetworkTool.ps1

The guide below (provided by https://github.com/sanderkl), will walk through the pre-requisite steps regarding creating your API key as well as ensuring your Organization is configured to use APIs.

## Enable Rest API Access for the organization

API key has to be organization wide enabled, to do that, go to organization settings

![Image Meraki dashboard](https://imgur.com/LBzIhK3.png)

Scroll down to 'Dashboard API access' and tick the box to enable it.

![Image Meraki dashboard](https://imgur.com/iOXTiEJ.png)

## Create API key for your user

Go to profile settings

![Image Meraki dashboard profile link](https://imgur.com/ymjzujI.png)

In your profile, scroll down to 'API access'

![Image Meraki dashboard new API key](https://imgur.com/Dbux0J5.png)

Generate a new rest api key.

# Import API Key
Once launched, you'll need to start by uploading/importing your API Key. <br>
You'll be immediately prompted on first launch to enter an API Key. <br>
<br>
<img src="https://i.imgur.com/b48RcwC.png" alt="API_Instruction"/><br>
This will create an encrypted version of the imported API to file that MNCT will use during the use of the application. <br>
(The path of the encrypted file is stored under ./API/API-Key.xml) <br>
Once created and MNCT has launched, close MNCT completely and re-open. This will re-establish the key into the application. <br>

# Import Organizations
Once launched, you'll need to import organizations into MNCT. To do this, select "Import Organizations" <br>
This will create a file under ./Organizations/ for each organization that your Meraki Account has access to. <br>
Once the Organizations have been created under the Organizations path, you must restart MNCT again to re-establish the organizations. (This will be fixed in later revisions) <br>
