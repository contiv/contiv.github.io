---
layout: "documents"
page_title: "Networking concepts"
sidebar_current: "networking-concepts"
description: |-
  Networking concepts
---

# Concepts and Terminology

Using container networking with Contiv is as easy as creating networks
and assigning containers to the networks. Contiv's real power, however, is the ability to 
apply policies that govern the security, bandwidth, priority, and other parameters for container
applications. Following are some concepts and terminoilogy required to understand
Contiv's policy framework.

## Containers vs. VMs

![ContivVms](/assets/images/ContvsVM.png)

Containers are a more efficient use of resources than Virtual Machines(VMs). VMs isolate resources at the operating system level. Containers share a single Operating System and kernel between isolated tenants, reducing time spent in patching and updating several operating systems.

## Groups
A *group* (or an *application group*) identifies a policy domain for a *container*
or a *pod*.  The grouping is an arbitrary
collection of containers that share a specific application domain, for example
all *production,frontend* containers, or *backup,long-running* containers.
This association is often done by specifying `label` in `kubernetes pod spec` 

Most notably, an application group or tier in Contiv has no one-to-one mapping
to a network or an IP subnet of a network. This encourages you to group
applications based on their roles and functions, and enables you to have many such application
groups belong to one network or an IP subnet.

## Policies
A *policy* describes an operational behavior on a *group* of containers. The operational
behavior can be enforcement, allocation, prioritation, traffic redirection,
stats collection, or other action on the group on which the policy is applied. For
example, an inbound security policy on a database tier can specify the allowed ports
on the containers belonging to the group.

A group can be associated with more than one policy. In such cases all policies are
applied to a container belonging to the group. For example, a bandwidth policy
could specify a limit on bandwidth consumption, while a security policy specifies
from which addresses the container can be accessed. When a container is scheduled
in this group, both policies are applied to it.

Policies follows the container independent of where it gets scheduled. Therefore, policy
is specified for a given cluster, but enforcement done on the host where container is
scheduled.

## Network
*Network* is an IPv4 or IPv6 subnet that may be provided with a default gateway. For
example, a network can map to a subnet `10.1.1.0/24` that has a default gateway
of `10.1.1.1`.

Application developers usually don't care which network an application belongs to.
The network association of an application becomes relevant when the application
must be exposed to an external network, possibly allowing non-container workloads
or clients to communicate with it.

*Note*: The following two paragraphs are intended for more advanced network users.

Contiv allows you to define two types of networks: An *application network* and
an *infrastructure network*. An application network is used by container workloads,
whereas the purpose of an *infrastructure network* is to create a virtual network
in the host namespace. For example, infrastructure networkws are used by the virtual 
layer of host-resident infrastructure services such as monitoring, storage, or cluster stores.

Network encapsulation *type* determines if a network is a *routed* network or a *bridged*
network. A routed network is useful in *overlay* topology and *L3-routed BGP* topology,
while a *bridged* network is useful in connecting to a *layer2 VLAN* network.

## Tenant
*Tenants* provides namespace isolation for networks. A tenant can have many *networks*,
each with its own subnet address, among other information. A user can create
networks with arbtrary subnet addresses within a tenant namespace, possibly reusing
subnet IP addresses in other tenants. This provides complete freedom to a tenant
user to specify the network names and their subnets within a tenant.

*Note*: The following two paragraphs are intended for more advanced network users.

A *tenant* in the physical network is called virtual routing and forwarding (VRF).
Depending on the mode of external connectivity (layer2, layer3, or
Cisco ACI), the Contiv forwarding layer communicates the *tenant* to the external network
using a *VLAN* or *VXLAN* ID. The Contiv routing plane (like BGP) is
used to communicate the VRF-ID to rest of the network. See the documentation
on layer3 BGP network configuraiton to learn more about configuration and usage.

Note that for *overlay* networks, the need to communicate the tenant to the external network
is not applicable.
