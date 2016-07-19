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

Thus, Contiv Network provides a pluggable networking alternative to built-in Docker, Kubernetes,
Mesos, and Nomad ecosystems.

To learn about container networking basics, including descriptions of both models, 
read our self-guided hands-on [Tutorial](/documents/tutorials/container-101.html).

## Learning Resources
Other learning resources on this site, designed to help you get up to speed on Contiv and container networkinginclude:

- [Contiv Features](/documents/networking/features.html)
- [Concepts and Terminology](/documents/networking/concepts.html)
- [Policies](/documents/networking/policies.html)
- [Service Routing](/documents/networking/services.html)
- [Physical networks](/documents/networking/physical-networks.html)
    - [L3 routed networks](/documents/networking/bgp.html)
    - [L2 bridged networks](/documents/networking/l2-vlan.html)
    - [Cisco ACI](/documents/networking/l2-vlan.html)

- [IPAM and Service Discovery](/documents/networking/ipam.html)
- [IPv6](/documents/networking/ipv6.html)

## Supported Modes

Contiv supports the networking modes and schedulers shown in the table below. To learn about and try the various combinations, see the Contiv Network [Getting Started](/documents/gettingStarted/networking/index.html) page.

|Fabric  | Kubernetes | Docker Swarm | Mesos | Nomad |
|--------+------------+--------------+-------+-------|
| **Layer 2** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |
| **Layer 3** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |
| **Overlay (cloud)** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |
| **ACI**     | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |

Please [submit an issue](https://github.com/contiv/netplugin/issues) if you
would like to suggest a feature or enhancement to be addressed by Contiv developers and contributors.

