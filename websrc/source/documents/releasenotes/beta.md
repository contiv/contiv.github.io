---
layout: "documents"
page_title: "Beta Release Notes"
sidebar_current: "release-notes-beta"
description: |-
  February 10, 2017
---

# Beta Release Notes

Welcome to the release of Contiv 1.0.0-beta. Contiv offers the most powerful open source container networking available. 

  feedback through our [Slack channel](https://contiv.slack.com) and Github .

A generally available version will release in the coming weeks with the option of commercial support.


## Features

This release includes:

- [Installer](https://github.com/contiv/install) Install Contiv on your existing Docker Swarm or Kubernetes 1.4+ system.
- Security features - Authorization and authentication available to system administrators.
- Networking Support
	- L2 (VLAN)
	- L2 Overlay (VXLAN)
	- L3
	- ACI
- [Contiv UI](https://github.com/contiv/contiv-ui), the first user interface available for administrators and users of Contiv. 
![ui](/assets/images/Dashboard.png)


## Supported Versions

Host OS

- CentOS 7.x

Container Schedulers / Orchestrators

- Kubernetes 1.4 
- Docker 1.12 + Docker Swarm 1.2.5

Infrastructure Support

- Bare metal
- vSphere
- AWS


## Limitations

- Health checks unavailable on VXLAN.
- nodeport configuration for Kubernetes is local-host only.  
 