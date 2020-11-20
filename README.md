# MNCT
Meraki Network Configuration Tool (Version 1.9.5)

Special thanks to some hard work from https://github.com/sanderkl. Several modules were forked from his hard work on his PS-Meraki project which are utilized within MNCT.

## Purpose for this Project
This project began development when my team and I were looking for an easy, automated and streamlined process for managing and making changes on hundreds of Meraki networks. The API offers the flexibility that allows us to automate this, but to make this fast, easy to use as well as a modular, I began development of this project. The project as of writing is currently in Beta stages and has known issues that are currently being addressed, however MNCT still offers a wide variety of unique automation features that can assist and cut down time with Network Management.

The tool itself is a mere collection of several automated tasks, modules and procedures that has saved us hours of time and effort. Version 1.9.5 is the first public release of this open sourced project that has continually received daily and weekly revisions. The project is now migrating towards a more robust change control process that will allow for better version control and history through github.

A Separate piece of the project will provide information on current list of all features, known bugs, feature updates, requests as well as new changes to the project.
More information on this is soon to arrive.

## Author Notes
Given the short age of the project, I will continue to provide source documentation as well as use cases for how the tool requires its use. As any code online, always review before running in your environment and gain the proper approvals before utilizing this application. Along with this, please review the licensing statement attached to the project.

USE AT YOUR OWN RISK. I am not responsible for any disasters, incidents or issues caused by improper use of the tool or code provided. I will offer assistance and support as time permits, but ensure that there is an understaning of the tools limitations, how it works and how the code works. It is  HIGHLY recommended to test the tool and get a feel for how it works using the Cisco DevNet Sandbox.https://developer.cisco.com/site/sandbox/

Understand that some use case scenarios of the tool and its features have been designed around scenarios that may be entirely unlike your Meraki environment. In this case, by all means, edit and fork new versions of this to your hearts desire to fit the needs of you and your organization.

## MNCT Features
1. Creation/Update of VLANs and configuration (VPN, DNS, VLAN Information) <br>
2. Creation/Update of Dynamic SSIDs, PSKs, Configuration, authentication settings.. <br>
3. Creation/Import/Update of Network Devices (MX,MR,MS,MG,MV) <br>
4. Import/Update Fixed IP Assignments to VLANs <br>
5. Route Table Export/Import Checker (VPN Conflict) <br>
6. Network Configuration Import of the following: <br>
   a. L3, L7 Firewall Rules <br>
   b. Content Filtering <br>
   c. Devices and Device configuration <br>
   d. Location <br>
   e. Intrusion Detection <br>
   f. Tags <br>
   g. Traffic Shaping <br>
   h. Threat Protection <br>
   i. VLAN/DHCP/DNS Import <br>
7. Network configuration Backup to file (Export), Network Configuration Import from file.<br>
8. Update Appliance Per-Port VLAN Settings <br>
9. Mass/Bulk Update Networks of following information:<br>
   a. Mass/Bulk update names (Append to Front, End, Overwrite and Append) <br>
   b. Update Security Settings (Threat Protection, IDS, Content Filtering, Traffic Shaping, Syslog) <br>
   c. Mass/Buulk update the following Firewall configuration: <br>
      i. L7 Firewall Rules <br>
      ii. L3 Firewall Rules (Apply to Top, Bottom, or Remove Firewall Rules) <br>
   d. Update Tags (Overwrite, Append, Apply all VLAN Subnets as individual tags on the network) <br>
   e. Update/Add new or existing SSID/Wireless Networks <br>
   f. Alerts <br>
   g. Location <br>
   h. VLANs (or specifically mass update VLAN Names) <br>
   i. Add/Update/Remove Network Devices, Device Name, Notes, Address and Tags <br>
   j. Mass Import Custom API to many networks (Use any API call that has not been created as a feature for added flexibility) <br>
10. Secure API embedded in GUI <br>
11. Import Organization information <br>
12. Flexible and Customizable Creation of Networks <br>
13. Bulk Switch Configuration Utility GUI Module <br>
14. Custom API Builder GUI Module <br>
15. Task Scheduler, Task builder and report builder <br>

## Known Bugs
This is a bug tracker that will be consistently updated as bugs are found and reported. <br>
1. Appliance IP when creating or updating VLANs is not currently enforced. (In Progress) <br>
2. Tag Overwite option may display as an available option when bulk updating networks. This is not an added or supported feature and is a GUI related bug. (In Progress) <br>
3. When updating a single network, subnets as tags may not consistently work. (In Progress) <br>
4. No current functionality for DELETE using API Builder. (In Progress) <br>
5. No current functionality for viewing, importing VLANs from Networks that contain more than three VLANs (Major change in progress for this) <br>
6. VLAN Import does not currently import VPN settings into MNCT. <br>
7. Switch Settings option in SBCU currently has no functionality supported. <br>
8. Updating L3 or L7 Firewall rules on more than 10+ Networks with the VERBOSE option enabled can cause the application to hang (Reviewing)

## New Feature Requests and project plans
1. Add a Remove L7 FW rules option <br>
2. Better SSID features and support (Easier use along with customization of features and settings) <br>
3. Better and Improved Network Configuration Import/Exports <br>

# Getting Started
Download the entire repository and start by launching MerakiNetworkTool.ps1
At this time, the project supports and has been tested using Powershell 5.1+
Given the age and infancy of the project, it is highly recommended to use Powershell ISE or VSCode to launch the project. It's also recommended to allow debugging.

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
