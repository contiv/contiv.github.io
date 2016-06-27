---
layout: "documents"
page_title: "Networking concepts"
sidebar_current: "networking-concepts"
description: |-
  Networking concepts
---

## Concepts and Terminology

Using container networking with Contiv is as easy as creating network(s)
and associating containers to belong to respective networks. However, one can optionally
apply the policies that govern the security, bandwidth, priority, etc. for container
applications. Subsequent sections go over some concepts and terminilogy to understand
the policy framework with Contiv.

#### Groups
A group (or an application-group) identifies a policy domain for a `container`
or a `pod`. This association is often done by specifying `label` in
`kubernetes pod spec` or `--net` in `docker run`. The grouping is arbitrary
collection of containers that share a specific application domain, for example
all `production,frontend` containers, or `backup,long-running` containers.

Most notably, application grouping or tiers in Contiv has no one-to-one mapping
to a network or an `IP subnet` of a network. Therefore, it is encouraged to group
applications based on their roles/functions, and possibly have many such application
groups belong to one network or an IP subnet.

#### Policies
A policy describes an operational behavior on a group of containers. The operational
behavior can result into enforcement, allocation, prioritation, traffic redirection,
stats collection, etc. on the corresponding group on which  the policy is applied. For
example an inbound security policy on a `database` tier can specify the sepcific set
of ports to be allowed towards the containers belonging to the group corresponding.

A group can be associated with more than one policy. In such cases all policies are
applied to a container belonging to the group. For example, if a `bandwidth policy`
specifices the limit on the bandwidth consumption, where as a security policy specifies
who can this container is allowed to talk to, then when a container is scheduled, the
both policies is applied to it.

Policies follows the container independent of where it gets scheduled, therefore policy
is specified for a given cluster, but enforcement done on the host where container is
scheduled.

#### Network
Network is an IPv4 or IPv6 subnet that may be provided with a default gateway. For
example, a network can map to `10.1.1.0/24` is a subnet which has a default gateway
of `10.1.1.1`.

Application developer usually doesn't care about the `network` an application would
belong to. Network association of an application becomes relevant when the application
needs to be exposed to external network, possibly allowing non-container workloads
or clients to communicate with it.

TL;DR (only for networking experts)

Contiv allows defining two types of networks: `application-network` and
`infrastructure-network`. An application network is used by container workloads
where as the purpose of `infrastructure-network` is to create a virtual network
in the host-name space, for example to be used by virtual layer of host-resident
infrastructure services e.g. monitoring services, storage services, or a
cluster-store.

Network encap `type` determines if a network is a `routed` network or a `bridged`
network. A routed network is useful in `overlay` topology and `l3-routed bgp` topology,
where as `bridged` network is useful in connecting to a `layer2 vlan` network.

#### Tenant
Tenant provides namespace isolation for networks. A `tenant` can have many `networks`,
each with its own subnet address among other information. User can create
networks with arbtrary subnet addresses within a tenant namespace, possibly reusing
subnet IP addresses in other tenants. This provides complete freedom to a tenant
user to specify the network names and their subnets within a tenant.

TL;DR (only for networking experts)

A `tenant` in the physical network is called VRF (virtual routing and forwarding),
therefore depending on the mode of external connectivity (layer2, layer3, or
Cisco ACI), Contiv forwarding layer communicates the `tenant` to the external network
using a `vlan` or `vxlan` id. On the other hand, Contiv routing plane (like BGP) is
used to communicate the VRF-ID to rest of the network. Please visit documentation
on layer3 BGP network configuraiton to learn more about configuration and usage.

Note that for `overlay` networks, the need to communicate tenant to external network
is not applicable.
