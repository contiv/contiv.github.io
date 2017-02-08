---
layout: "documents"
page_title: "Beta Release Notes"
sidebar_current: "release-notes-beta"
description: |-
  February 6, 2017
---

# Beta Release Notes

Welcome to the Beta release of Contiv 1.0.0. Contiv is the most powerful open source container networking platform available. 


## Features

This release includes:

- Contiv auth_proxy, allowing you to:
	- Establish role-based access for your container network
	- Check user authorizations
	- Authenticate using LDAP
	- Set up BGP Nodes 
- Contiv UI, the first UI available for administrators and users of Contiv. 
- [Contiv Installer](https://github.com/contiv/install) Install Contiv on your existing Docker Swarm or Kubernetes 1.4+ system.


## Support

Host OS

- CentOS7

Container schedulers / orchestrators

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

Forwarding plane / method

- Open vSwitch
- Openflow


## Known Issues

- **auth_proxy** Set SELinux to permissive mode before building Contiv. SELinux cannot be in enforcing mode, you must disable SELinux to build Contiv.  

