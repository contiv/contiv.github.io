---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "networking"
description: |-
  Getting Started
---

# Contiv Features

Contiv Networking supports the following features:

- A feature-rich policy model to provide secure, predictable application deployment
- Best-in-class throughput for container workloads
- Multi-tenancy, isolation, and overlapping subnets
- Integrated IPAM and service discovery
- A variety of physical topologies:
    - Layer2 (VLAN)
    - Layer3 (BGP)
    - Overlay (VXLAN)
    - Cisco SDN Solution (ACI)
- IPv6 Support
- Scalable policy and route distribution
- Integration with application blueprints, including:
    - Docker Compose
    - Kubernetes deployment manager
- Service Load Balancing: built in east-west microservice load balancing
- Traffic isolation for storage, control (for example, etcd/consul), network, and management traffic

To learn about container networking basics, read our self-guided hands-on
[Tutorial](/documents/tutorials/container-101.html). The tutorial discusses
libnetwork's CNM and CoreOS's CNI model. Contiv supports both networking models,
and therefore supports a pluggable networking alternative to built-in Docker, Kubernetes,
Mesos, and Nomad ecosystems.
