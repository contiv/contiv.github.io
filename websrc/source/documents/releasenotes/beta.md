---
layout: "documents"
page_title: "Beta Release Notes"
sidebar_current: "release-notes-beta"
description: |-
  February 10, 2017
---

# Beta Release Notes

Welcome to the release of Contiv 1.0.0-beta. Contiv offers the most powerful open source container networking available. 


## Features

This release includes:

- [Contiv Installer](https://github.com/contiv/install) Install Contiv on your existing Docker Swarm or Kubernetes 1.4+ system.
- Contiv auth_proxy, allowing you to:
	- Establish role-based access for your container network
	- Check user authorizations
	- Authenticate using LDAP
	- Set up BGP Nodes 
- Contiv UI, the first user interface available for administrators and users of Contiv. 



## Support

Host OS

- CentOS 7

Container Schedulers / Orchestrators

- Kubernetes 1.4 
- Docker 1.12
- Docker Swarm 1.2.5

Infrastructure Support

- Bare metal
- vSphere
- AWS

Networking Models

- L2 (VLAN)
- L2 Overlay (VXLAN)
- L3
- ACI

Forwarding Plane / Method

- Open vSwitch
- Openflow


## Known Issues

- **auth_proxy** Set SELinux to permissive mode before building Contiv. SELinux cannot be in enforcing mode, you must set SELinux to permissive mode to build Contiv.  

