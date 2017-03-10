---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "getting-started"
description: |-
  Getting Started
---

# Getting Started
Begin using Contiv right away with our [Quick Start demo](https://github.com/contiv/install/blob/master/QUICKSTART.md). 

##[Contiv Features](/documents/networking/features.html)
See the latest features in Contiv.

## [Concepts](/documents/networking/concepts.html)
Learn more about the ideas and terms most commonly used in container networking.

##[Install](https://github.com/contiv/install/blob/master/README.md)
Follow the instructions for the Contiv Installer to install Contiv on your Docker Swarm or Kubernetes container.

##[Networking](/documents/networking/)
Set up a development environment or a cluster of servers using different clustering systems.

##What is Contiv?

Contiv delivers policy-based container for Networking. Contiv makes it easier for you to deploy micro-services in your environment.

Contiv provides a higher-level of networking abstraction for microservices and secures your application using a rich policy framework. It provides built-in service discovery and service routing for scale out services.

With the advent of containers and Microservices architecture, there is a need of automated or programmable network infrastructure specifically catering to dynamic workloads which can be formed using containers. With container and microservices technologies, speed and scale becomes critical. Because of these requirements, Automation becomes a critical component in the Network provisioning for future workloads.

Also with Baremetal hosts, VMs, and containers, there are different layers of Virtualization abstraction, complicating packet encapsulation. With public cloud technologies, tenant level isolation is necessary as well for our container workloads.

Contiv provides an IP address per container and eliminates the need for host-based port NAT. It works with different kinds of networks like pure layer 3 networks, overlay networks, and layer 2 networks, and provides the same virtual network view to containers regardless of the underlying technology. Contiv works with all major schedulers like Kubernetes and Docker Swarm. These schedulers provide compute resources to your containers and Contiv provides networking to them. Contiv supports both CNM (Docker networking Architecture) and CNI (CoreOS, the Kubernetes networking architecture). Contiv has L2, L3 (BGP), Overlay (VXLAN) and ACI modes. It has built in east-west service load balancing. Contiv also provides traffic isolation through control and data traffic.

Contiv is made of two major components:

* Netmaster
* Netplugin (Contiv Host Agent)

The following Contiv architecture diagram shows how Netmaster and Netplugin provide the Contiv solution:

![ContivArch](/assets/images/Contiv-HighLevel-Architecture.png)

####Netmaster
Netmaster is one binary that performs multiple tasks for Contiv. It's a REST API server that can handle multiple requests simultaneously. It learns routes and distributes to Netplugin nodes. It acts as resource manager which does resource allocation of IP addresses, VLAN and VXLAN IDs for networks. It uses distributed state store like etcd or consul to save all the desire runtime of for Contiv objects. Because of this, Contiv becomes completely stateless, scalable, and restart-able. Netmaster has in built heartbeat mechanism, through which it can talk to peer netmasters. This avoids risk of single point failure. Netmaster can work with external integration manager (Policy engine) like ACI.

####Netplugin
Each Host agent (Netplugin) implements CNI or CNM networking model adopted by popular container orchestration engines like Kubernetes and Docker Swarm, etc. It does communicate with Netmaster over REST Interface. In addition to this, Contiv uses json-rpc to distribute endpoints from Netplugin to Netmaster. Netplugin handles Up/Down events from Contiv networks and groups. It coordinates with other entities like fetching policies, creating container interface, requesting IP allocation, programming host forwarding.

Netplugin uses Contiv's custom open-flow based pipeline on linux host. It communicates with Open vSwitch (OVS) over the OVS driver. Contiv currently uses OVS for their data path. Plugin architecture of Contiv, makes it very easy to plug in any data path (eg: VPP, BPF etc).