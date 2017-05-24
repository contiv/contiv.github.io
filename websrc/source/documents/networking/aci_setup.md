---
layout: "documents"
page_title: "Cisco ACI"
sidebar_current: "getting-started-networking-installation-aci"
description: |-
  Setting up ACI 
---

# Installing Contiv Network with Cisco ACI
This page gives brief instructions for installing Contiv Network with Cisco's Application Centric Infrastructure (ACI).

For more information about ACI, contact [Cisco Systems](http://www.cisco.com/c/en/us/solutions/data-center-virtualization/application-centric-infrastructure/index.html).

## Prerequisites

Configure your APIC Fabric and Access Policies as follows:


1. Create a VLAN Pool under *Fabric* -> *Access Policies* -> *Pools* -> *VLAN*. Set allocation mode to
   *Static Allocation*.

2. Create a physical domain under *Fabric* -> *Access Policies* -> *Physical and External Domains* -> *Physical Domains*.

3. Create an attachable access entity profile (AAEP) and associate it with the physical domain created in Step 2.

4. Create a Policy Group (under *Interface Policies*) and specify the AAEP created in Step 3.

5. Create an Interface Profile and specify the physical interfaces connected from your ToRs to the bare metal servers. 
You can create separate Interface Profiles for individual ToRs if you like.

6. Create a Switch Profile (*Switch Policies/Profiles*) and specify the appropriate interface profile created in Step 5.

7. Make a note of the full node names of the ToRs you have connected to your servers.

## Configure the ACI Gateway Container

To enable the ACI-GW to access and configure ACI to match the Contiv configuration, set these environment 
variables (see configuring aci under Installation): 

`APIC_URL` - The URL of the APIC.

`APIC_USERNAME` - The login username for the APIC.

`APIC_LEAF_NODE` - The full URI path of the ACI leaf nodes where the cluster servers are connected,
for example, `topology/pod-1/node-101`. If there are multiple nodes, you can use comma separation,
for example, `topology/pod-1/node-101,topology/pod-1/node-102`.

`APIC_PHYS_DOMAIN` - The name of the physical domain used for the Contiv cluster (Step 2 above).

## Set Up Authentication
Both key-based authentication and password authentication are supported. Key-based authentication is the recommended method.

### Password-Based Authentication

For password-based authentication, pass the password to the ACI-GW using the `APIC_PASSWORD` environment variable.

### Key-Based Authentication
To enable key-based authentication, follow these steps:

1. Create a Key 
Create a key and certicate. Add the certificate to APIC using the procedure described 
[here](http://www.cisco.com/c/en/us/td/docs/switches/datacenter/aci/apic/sw/kb/b_KB_Signature_Based_Transactions.pdf).

2. Set the APIC_CERT_DN Environment Variable in aci config
Find the distinguished name (DN) of the key that was added to APIC and pass it to the ACI-GW via the `APIC_CERT_DN` environment variable. 
This DN is of the form *uni/userext/user-admin/usercert-admin* The exact DN can be found from the APIC visore, 
for example, `APIC_CERT_DN=uni/userext/user-admin/usercert-admin`.

3. Create a Key Directory
Create a directory on the server that hosts ACI-GW and copy the key created in the previous step to this directory.

4. Share the key and restart aci_gw container 
<b>TBD: this step is potentially different in k8s vs swarm environment.</b>
Share this directory with the ACI-GW using the bind mounting option of Docker.
For example, if the keys are copied to the `/shared/keys` directory on the host, 
use the `-v /shared/keys:/aciconfig` option while starting the ACI-GW container.
