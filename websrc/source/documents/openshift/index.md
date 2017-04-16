---
layout: "documents"
page_title: "Contiv and Openshift"
sidebar_current: "openshift"
description: |-
  Contiv and OpenShift
---

#Contiv support for OpenShift

Contiv is a certified plugin for Openshift (both Openshift Origin and Openshift Enterprise/ Red Hat Container Platform).  

**Note:** This feature is currently in Alpha status; refer to the supported features list and community support details below. If you have questions, [sign up for Slack](https://contiv.herokuapp.com/) and ask us on our [Slack channel](https://contiv.slack.com). Contact your support representatives from Red Hat and Cisco for details on the enterprise support plan and timelines.

##Using Contiv and OpenShift

The Contiv installer is integrated with the standard [Openshift Ansible-based installer](https://docs.openshift.org/latest/install_config/install/advanced_install.html) for both Openshift Origin and Openshift Enterprise (Red Hat Container Platform). In order to install and use Openshift with Contiv, the basic procedure is to install Openshift using its Ansible installer with its standard Openshift installation playbook and set some ansible inventory configuration parameters such that Contiv is also installed during the Openshift installation itself. This will result in a single combined installation process which results in both Openshift and Contiv being installed via Ansible in a single step.  In order to run this combined playbook,

##Current community supported configurations, features

1. Openshift Origin (version 1.3.0 or later)
2. Openshift Enterprise/ Red Hat Container Platform (version 3.5.0 or later). 
3. Openshift Enterprise 3.4.0 supported via install from ansible source (3.4 Openshift Ansible yum package not supported).
4. All standard Openshift features including Openshift Registry, Openshift Router (with default HAProxy load balancer)
5. Contiv 1.0.0 release
6. Bare metal server deployments only (Centos7 or Rhel7)
7. Contiv L2 VLAN networking mode only

Notes:
1. Currently we recommend inquiring on the [Contiv community slack channel](https://contiv.slack.com) for technical support and questions for initial trials and POCs. Please contact your Cisco and Red Hat support representatives for exact official status and timelines for enterprise level support options.

2. Contiv installer is available in yum packages for Openshift enterprise from 3.5 onwards. For Openshift Enterprise 3.4 and for Openshift Origin 1.3 and 1.4, the Contiv installer is available in the Openshift Ansible github repo master branch and hence may be installed by pulling the Openshift Ansible installer from github directly. An example of this installation is provided below.

## Installation example for Openshift + Contiv

In this example, we shall illustrate a single combined installation of Openshift and Contiv together and shall use the Openshift Ansible directly from github to do this. In this example, we have an Ansible installer/ management node installing Openshift + Contiv onto 4 bare metal servers resulting in 1 Master + 3 Nodes in the resulting Openshift cluster. 

1. Clone the standard Openshift Ansible repo directly (git clone https://github.com/openshift/openshift-ansible.git)
2. Edit the ansible inventory file to match the desired master and node topology and IP addresses of your target bare metal machines. The Openshift documentation (see for example [here](https://docs.openshift.org/latest/install_config/install/advanced_install.html) and [here](https://docs.openshift.com/container-platform/3.4/install_config/install/advanced_install.html)) has examples of Ansible inventory files for typical cluster deployments.
3. Edit the ansible inventory file to use Contiv as the networking plugin instead of the default Openshift SDN and set additional configuration parameters to match your cluster topology and contiv network settings. (an example of the Contiv configuration parameters is in the following section).
4. Run the Ansible playbook for the BYO machines case (i.e. "ansible-playbook -i <your_inventory_file> ./playbooks/BYO/config.yml").

Thats it, you now have a running Openshift cluster which uses Contiv as its networking layer.

**Note:** Ansible 2.2.0 or later is recommended for deploying via the Openshift + Contiv Ansible playbook.

## Example Ansible inventory file for deploying Openshift Origin + Contiv

Please refer to the [Openshift documentation](https://docs.openshift.org/latest/install_config/install/advanced_install.html) for full details on Openshift configuration. Here we list an example of adapting one of the inventory files from the Openshift documentation examples to substitute Contiv in place of the default Openshift SDN. This example illustrates set up for an Openshift Origin cluster running version 1.4.1. Contiv is enabled via the variable "openshift_use_contiv" and by setting "openshift_use_openshift_sdn" to "false" as well as other parameters as shown below. "netplugin_interface" is the contiv data plane vlan interface, "netmaster_interface" is the control plane interface, "netplugin_fwd_interface" set to "bridge" sets Contiv in L2 vlan mode. The default subnet (for pod IPs), default gateway and VLAN tag are set via  "contiv_default_subnet", "contiv_default_gw" and "contiv_default_network_tag".  When this playbook is executed, a default container network (called "default-net") will also be set up and will use these parameters. Note that since this is the L2 VLAN mode of Contiv, the data plane VLANs and default gateway will also need to be setup externally in the physical network that the cluster uses. 

```
# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=admin

# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true

deployment_type=origin

openshift_version=1.4.1
openshift_release=v1.4

os_firewall_use_firewalld=false

openshift_use_openshift_sdn=False
openshift_use_contiv=True
os_sdn_network_plugin_name='cni'

netplugin_interface=net3
netmaster_interface=net1
netplugin_fwd_mode=bridge
contiv_default_subnet="29.70.0.0/24"
contiv_default_gw="29.70.0.1"
contiv_default_network_tag="2970"

```

