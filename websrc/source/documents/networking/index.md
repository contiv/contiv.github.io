---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "networking"
description: |-
  Getting Started
---

## Contiv Networking

To learn about container networking basics you can find a self guided hands-on
[Tutorial](/documents/tutorials/container-101.html). The tutorial discusses
libnetwork's CNM and CoreOS's CNI model. Contiv supports both networking models,
and therefore support a pluggable networking alternative to built-in Docker, Kubernetes,
Mesos and Nomad ecosystems.

Contiv Networking supports following use cases:

- Feature rich policy model to provide secure, predictable application deployment
- Best in the class throughput for container workloads
- Multi-tenancy, Isolation, and overlapping subnets
- Integrated IPAM and service discovery
- Variety of physical topological connectivity:
    - Layer2(vlan)
    - Layer3(BGP)
    - Overlay(VXLAN)
    - Cisco SDN Solution (ACI)
- IPv6 Support
- Policy and route distribution scale
- Integration with application blue-prints like:
    - docker-compose
    - kubernetes deployment-manager
- Service Load Balancing: built in east west microservice load balancing
- Traffic isolation for storage, control (e.g. etcd/consul), network, and management traffic

<br>
Please check or [submit an issue](https://github.com/contiv/netplugin/issues) if you
would like a feature to be addressed by Contiv.

# Table of Contents

- [Concepts and Terminology](/documents/networking/concepts.html)
- [Policies](/documents/networking/policies.html)
- [Service Routing](/documents/networking/services.html)
- [Physical networks](/documents/networking/physical-networks.html)
    - [L3 routed networks](/documents/networking/bgp.html)
    - [L2 bridged networks](/documents/networking/l2-vlan.html)
    - [Cisco ACI](/documents/networking/l2-vlan.html)

- [IPAM and Service Discovery](/documents/networking/ipam.html)
- [IPv6](/documents/networking/ipv6.html)


# Supported modes

Contiv supports various fabric networking modes and schedulers. In order to tryout the various combination please checkout our contiv networking [installation](/documents/gettingStarted/networking/index.html) page

|Fabric  | Kubernetes | Docker Swarm | Mesos | Nomad |
|--------+------------+--------------+-------+-------|
| **Layer 2** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |
| **Layer 3** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |
| **Overlay (cloud)** | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |
| **ACI**     | <i class="fa fa-check fa-2x"></i>| <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> | <i class="fa fa-check fa-2x"></i> |
