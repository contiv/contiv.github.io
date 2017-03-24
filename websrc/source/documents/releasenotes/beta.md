---
layout: "documents"
page_title: "Beta Release Notes"
sidebar_current: "release-notes-beta"
description: |-
  February 10, 2017
---

# Beta Release Notes

Welcome to the release of Contiv 1.0.0-beta. Contiv offers the most powerful open source container networking available. 

For any questions on Beta, you can [sign up for Slack](https://contiv.herokuapp.com/) and ask us on our [Slack channel](https://contiv.slack.com). File any issues you find on our [Github](https://github.com/contiv).

**Note:** A GA (general availability) version will be released in coming weeks with the option of commercial support.

## Features

This release includes:

- [Installer](https://github.com/contiv/install) - Install Contiv on your existing Docker Swarm or Kubernetes 1.4+ system.
- [Security Features](https://github.com/contiv/auth_proxy) - Authorization and authentication available to system administrators.
- [Networking Support](https://github.com/contiv/netplugin)
	- L2 (VLAN)
	- L2 Overlay (VXLAN)
	- L3 (experimental)
	- ACI
- [Contiv UI](https://github.com/contiv/contiv-ui) - The first user interface available for administrators and users of Contiv.
![ui](/assets/images/Dashboard.png)


## Compatibility Matrix
Contiv can run on a variety of platform configurations such as on-premise or cloud and different flavors of Linux as host OS. However, we focus on specific configurations of platform components in our lab testing environment, as described below. Any platform specific feature restrictions and configuration requirements are also highlighted.


Host OS

- CentOS 7.x
- RHEL 7.x (upcoming)

Container Schedulers / Orchestrators

- Kubernetes 1.4 
- Docker 1.12.x + Docker Swarm 1.2.5
- Docker 17.03.x-ce (upcoming)

Infrastructure Support

- Bare metal
- vCenter
	- VM port group needs to be configured for correct networking mode (see [the VMWare documentation](https://pubs.vmware.com/vsphere-65/index.jsp?topic=%2Fcom.vmware.vsphere.networking.doc%2FGUID-D5960C77-0D19-4669-A00C-B05D58A422F8.html) for more details). For L2 or ACI mode, port group needs to be configured using VLAN trunking to allow Virtual Guest Tagging. For L3 mode, port group can be configured using no VLAN if using External VLAN Tagging or assign a VLAN in the Port Group for Virtual Switch Tagging.

- AWS (VXLAN only)

Integrated Container Platforms

- OpenShift Origin 1.4, OpenShift Enterprise 3.4 (upcoming)
- Docker Enterprise Edition (upcoming)


## Limitations

- Health checks unavailable on VXLAN.
- nodeport configuration for Kubernetes is local-host only.  
 
