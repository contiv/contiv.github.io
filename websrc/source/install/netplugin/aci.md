---
layout: "install"
page_title: "ACI setup"
sidebar_current: "getting-started-aci"
description: |-
  Setting up ACI.
---

## Setting Up Contiv Networking in ACI 

This document describes how to set up a Contiv Network cluster in ACI mode. The steps listed here are in addition to the steps presented in the [general README](https://github.com/contiv/demo/tree/master/net/README.md).

### Prerequisites for ACI Setup

#### VLANS

Contiv currently uses vlans starting from 100. Therefore, a block of vlans starting from 100 must be
 reserved for use by Contiv. (The vlan range will be made configurable in a subsequent release.)

### APIC Configuration: Fabric and Access Policies

    1. Create a physical domain named "allvlans" (For now, this name is hard-coded. The name will be made configurable in a follow-on release).

    2. Create a vlan pool with a block of vlans starting with 100 as described above. Set allocation mode to "Static Allocation" and associate the pool with the "allvlans" physical domain.

    3. Create an Attachable Access Entity Profile (AAEP) and associate it with the "allvlans" physical domain.

    4. Create a Policy Group (under Interface Policies) and specify the AAEP created in the previous step.

    5. Create an Interface Profile and specify the physical interfaces connected from your ToR(s) to the bare metal servers. You can create separate Interface Profiles for individual ToRs if you like.

    6. Create a Switch Profile (Switch Policies/Profiles) and specify the appropriate interface profile created in step 4.

    7. Make a note of the full node name(s) of the ToR(s) you have connected to your servers.

    8. Find the interface name of the NIC on the server that is connected to the ToR (e.g. eth5).

### Additional Configuration Information

A sample **cfg.yml** for ACI setup is at: [sample_aci_cfg.yml](https://github.com/contiv/demo/tree/master/net/extras/sample_aci_cfg.yml)

Apart from the usual information in the **cfg.yml** (as described [here](https://github.com/contiv/demo/tree/master/net/README.md#information-in-cfgyml)), the following additional details are required to provide access information to the APIC and the leaf(s) connected to the ACI topology.

All of the options listed below for ACI setup are mandatory.

#### General APIC Reachability Information
```
          APIC_URL: "https://<apic-server-url>:443"
          APIC_USERNAME: "admin"
          APIC_PASSWORD: "password"
```

#### Information Related to Leaf Nodes
Provide the full paths of the leaf nodes connected to your servers. Use the informtion obtained in Step 8 of [APIC Configuration](aci.md#apic-configuration-fabricaccess-policies) here.  

```
        APIC_LEAF_NODES:
        - topology/pod-1/node-101
        - topology/pod-1/node-102
```

### Running the Installer in ACI Mode
To run the installer in ACI mode use the -a option.  
```
          ./net_demo_installer -a
```

To restart the services once they are installed, use the -r option. This option ensures that the services are restarted in a clean state.  
```
          ./net_demo_installer -ar
```

### Starting Containers
The installer script downloads some basic containers (web/redis) that you can use to get started.
