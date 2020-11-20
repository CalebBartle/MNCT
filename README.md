# MNCT
Meraki Network Configuration Tool (Version 1.9.5)

Special thanks to some hard work from https://github.com/sanderkl.

## Purpose for this Project
This project began development when my team and I were looking for an easy, automated and streamlined process for managing and making changes on hundreds of Meraki networks. The API offers the flexibility that allows us to automate this, but to make this fast, easy to use as well as a modular, I began development of this project. The project as of writing is currently in Beta stages and has known issues that are currently being addressed, however MNCT still offers a wide variety of unique automation features that can assist and cut down time with Network Management.

The tool itself is a mere collection of several automated tasks, modules and procedures that has saved us hours of time and effort. Version 1.9.5 is the first public release of this open sourced project that has continually received daily and weekly revisions. The project is now migrating towards a more robust change control process that will allow for better version control and history through github.

A Separate piece of the project will provide information on current list of all features, known bugs, feature updates, requests as well as new changes to the project.
More information on this is soon to arrive.

## MNCT Features
1. Creation/Update of VLANs and configuration (VPN, DNS, VLAN Information)
2. Creation/Update of Dynamic SSIDs, PSKs, Configuration, authentication settings..
3. Creation/Import/Update of Network Devices (MX,MR,MS,MG,MV)
4. Import/Update Fixed IP Assignments to VLANs
5. Route Table Export/Import Checker (VPN Conflict)
6. Network Configuration Import of the following:
   a. L3, L7 Firewall Rules
   b. Content Filtering
   c. Devices and Device configuration
   d. Location
   e. Intrusion Detection
   f. Tags
   g. Traffic Shaping
   h. Threat Protection
   i. VLAN/DHCP/DNS Import
7. Network configuration Backup to file (Export), Network Configuration Import from file.
8. Update Appliance Per-Port VLAN Settings
9. Mass/Bulk Update Networks of following information:
   a. Mass/Bulk update names (Append to Front, End, Overwrite and Append)
   b. Update Security Settings (Threat Protection, IDS, Content Filtering, Traffic Shaping, Syslog)
   c. Mass/Buulk update the following Firewall configuration:
      i. L7 Firewall Rules
      ii. L3 Firewall Rules (Apply to Top, Bottom, or Remove Firewall Rules)
   d. Update Tags (Overwrite, Append, Apply all VLAN Subnets as individual tags on the network)
   e. Update/Add new or existing SSID/Wireless Networks
   f. Alerts
   g. Location
   h. VLANs (or specifically mass update VLAN Names)
   i. Add/Update/Remove Network Devices, Device Name, Notes, Address and Tags
   j. Mass Import Custom API to many networks (Use any API call that has not been created as a feature for added flexibility)
10. Secure API embedded in GUI
11. Import Organization information
12. Flexible and Customizable Creation of Networks
13. Bulk Switch Configuration Utility GUI Module
14. Custom API Builder GUI Module
15. Task Scheduler, Task builder and report builder

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
