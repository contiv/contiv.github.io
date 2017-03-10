---
layout: "documents"
page_title: "Network Defaults"
sidebar_current: "admin-setting-network-defaults"
description: |-
  Setting Network Defaults
---

# Managing Networks

Set the default parameters for networks your tenants will create in **Network Settings**. 

You can:

- Enable Cisco ACI if that is part of your network infrastructure
- Set VLAN and VXLAN ranges
- Determine forwarding mode
- Select the ARP mode

To set the network defaults.

1. Select **Settings > Network Defaults**.
2. Choose your network infrastructure type.<br>
   If you are using Cisco ACI, choose **Cisco ACI**, otherwise leave your infrastructure type as default.
3. Enter your desired VLAN range.
4. Enter your desired VXLAN range. 
5. Select your forwarding mode **bridge** or **routing**.
6. Select your Address Resolution Protocol (ARP) Mode, **proxy** or **flood** 
6. Click **Update Network Settings**. <br>

![CreateNetworkSettings](CreateNetworkSettings.png)

   You recieve a confirmation message confirming the update to your global settings.  
