---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "networking"
description: |-
  Getting Started
---

# Contiv Networking

Contiv Networking supports both major networking models:

- The libnetwork CNM model 
- The CoreOS CNI model

Thus, Contiv Network provides a pluggable networking alternative to built-in Docker and Kubernetes ecosystems.

To learn about container networking basics, including descriptions of both models, 
read our self-guided hands-on [Tutorial](/documents/tutorials/container-101.html).

## Learning Resources
The following resources are provided to help you get up to speed on Contiv and container networking:

- [Contiv Features](/documents/networking/features.html)
- [Concepts and Terminology](/documents/networking/concepts.html)
- [Policies](/documents/networking/policies.html)
- [Ports](/documents/networking/portinfo.html)
- [Service Routing](/documents/networking/services.html)
- [Physical networks](/documents/networking/physical-networks.html)
    - [L3 routed networks](/documents/networking/bgp.html)
    - [L2 bridged networks](/documents/networking/l2-vlan.html)
    - [Cisco ACI](/documents/networking/aci_ug.html)

- [IPAM and Service Discovery](/documents/networking/ipam.html)
- [IPv6](/documents/networking/ipv6.html)

## Supported Modes

Contiv supports the networking modes and schedulers shown in the table below. To learn about and try various combinations, see [Getting Started](/documents/gettingStarted/) page for how to [install](https://github.com/contiv/install/blob/master/README.md) in your environment, or in a [demo setup](https://github.com/contiv/install/blob/master/QUICKSTART.md).

|Fabric  | Kubernetes | Docker Swarm |  
|--------+------------+--------------|
| **Layer 2** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | 
| **Layer 3** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> |
| **Overlay (cloud)** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> |  
| **ACI**     | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> |

Please see [support](/documents/support/index.html) page on 
how to suggest a feature or enhancement to be addressed by Contiv developers and contributors.

