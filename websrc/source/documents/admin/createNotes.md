---
layout: "documents"
page_title: "Create Nodes (BGP)"
sidebar_current: "administrator-nodes-bgp"
description: |-
  Setting up nodes.
---

# Setting up Nodes for BGP

To allow your containters to talk to eachother, you will need an external gateway protocol. The Border Gateway Protocol (BGP) is the routing protocol that can alow your containers to contact eachother over large subnets or even more than one ISP. 

BGP is the protocol that internet servers use to communicate to each other about which way to go, and how they should update their routing tables.

Note: You will need some basic information on your BGP setup. Run _show ip bgp_ and _show ip bgp neighbors_ in order to obtain the neighbor IP address.

To set up nodes:

1. From **Settings > Nodes (BGP)** select **Create Node**.
2. Enter the Hostname for the BPG node.
3. Enter the Router IP address for your node and the Autonomous System number.
   For example 10.10.10.1 and 400. 
4. Enter the Neighbor IP address (where you will send the workload) and the Autonomous System number.
   For example 10.10.10.2 and 400.

