---
layout: "documents"
page_title: "Networking concepts"
sidebar_current: "networking-concepts"
description: |-
  Networking concepts
---

# Concepts 

Container networking with Contiv is as easy as creating networks
and assigning containers to the networks. The advantage of Contiv is that you can 
apply policies to govern the security, bandwidth, priority, and other parameters for container
applications.

## Containers vs. VMs

Containers are a more efficient use of resources than Virtual Machines(VMs). VMs isolate resources at the operating system level. Containers share a single Operating System and kernel between isolated tenants, reducing time spent in patching and updating several operating systems.

![ContivVms](/assets/images/ContvsVM.png)


## Groups
A *group* (or an *application group*) identifies a policy domain for a *container*
or a *pod*.  The grouping is an arbitrary
collection of containers that share a specific application domain, for example
all *production,frontend* containers, or *backup,long-running* containers.
This association is often done by specifying a label for the group.

Most notably, an application group or tier in Contiv has no one-to-one mapping
to a network or an IP subnet of a network. This encourages you to group
applications based on their roles and functions, and have many application
groups belong to one network or an IP subnet.

## Policies
A *policy* describes an operational behavior on a *group* of containers. The operational
behavior can be enforcement, allocation, prioritation, traffic redirection,
stats collection, or other action on the group on which the policy is applied.  

Contiv supports two types of policies:

* Bandwidth - limiting the overall resource use of a group
* Isolation - limiting the access of a group
 
A group can be associated with more than one policy and in this case all policies are
applied to the group. For example, a bandwidth policy
could specify a limit on bandwidth consumption, while an isolation policy specifies
from which addresses the container can be accessed. When a container is scheduled
in this group, both policies are applied to it.

Policies follow the container independent of where it is scheduled. Therefore, policy
is specified for a given cluster, but enforcement done on the host where container is
scheduled.

## Network
*Network* is an IPv4 or IPv6 subnet that may be provided with a default gateway. For
example, a network can map to a subnet `10.1.1.0/24` that has a default gateway
of `10.1.1.1`.

Application developers usually don't care which network an application belongs to.
The network association of an application becomes relevant when the application
must be exposed to an external network, to allow non-container workloads
or clients to communicate with it.


###Networks in Contiv
Contiv allows you to define two types of networks: 

* application network - Network used by container workloads
* infrastructure network - Create a virtual network in the host namespace. For example, infrastructure networks are used by the virtual 
layer of host-resident infrastructure services such as monitoring.

###Network Encapsulation
There are two types of network encapsulation in Contiv:

* Routed - useful for *overlay* topology and *L3-routed BGP* topology
* Bridged - useful for connecting to a *layer2 VLAN* network

## Tenant
*Tenants* provide the namespace isolation for Contiv. A tenant can have many *networks*,
each with its own subnet address. A user within that tenant namespace can create
networks with arbtrary subnet addresses, and re-use subnet IP addresses in other tenants. 

A *tenant* in the physical network is called virtual routing and forwarding (VRF).
Depending on the mode of external connectivity (layer2, layer3, or
Cisco ACI), the Contiv forwarding layer communicates the *tenant* to the external network
using a *VLAN* or *VXLAN* ID. The Contiv routing plane (like BGP) is
used to communicate the VRF-ID to rest of the network. 

