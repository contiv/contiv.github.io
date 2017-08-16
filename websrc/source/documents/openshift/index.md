---
layout: "documents"
page_title: "Contiv and Openshift"
sidebar_current: "openshift"
description: |-
  Contiv and OpenShift
---

#Using Contiv with OpenShift

Contiv is a certified plugin for Openshift (both Openshift Origin and Openshift Enterprise/ Red Hat Container Platform).  

**Note:** If you have further questions, [sign up for Slack](https://contiv.herokuapp.com/) and ask us on our [Slack channel](https://contiv.slack.com). Contact your support representatives from Red Hat and Cisco for details on the enterprise support plan and timelines.

##Using Contiv and OpenShift

An ansible based Contiv installer is pre-integrated with the standard Openshift Ansible-based installers for both [Openshift Origin](https://docs.openshift.org/latest/install_config/install/advanced_install.html) and [Openshift Enterprise (Red Hat Container Platform)](https://docs.openshift.com/container-platform/3.6/install_config/install/advanced_install.html). Simply using Openshift\`s own Ansible based installer (with some configuration/ inventory settings as shown in examples below) will result in a single combined installation process which results in both Openshift and Contiv being installed via Ansible in a single step.

##Current community supported configurations, features when using Contiv with Openshift

1. Openshift Origin (version 3.6 or later)
2. Openshift Enterprise/ Red Hat Container Platform (version 3.6 or later). 
3. All standard Openshift features including Openshift Registry, Openshift Router (with default HAProxy load balancer)
4. Contiv 1.1.1 release (automatically pre-installed with Openshift version 3.6 or later)
5. Bare metal or VM based deployments
6. Hosts must run Centos 7.x or RHEL 7.x as required by Openshift. Contiv currently does not support RHEL 7.x Atomic as the host OS.
7. Contiv may currently be used in either L3 (no BGP) VXLAN mode, L2 VLAN mode or ACI mode with Openshift. Use of Contiv in L3 BGP mode with Openshift is currently in experimental status and will be officially supported in future releases.
8. Subject to all standard common Openshift deployment requirements, [pre-requisites, and host preparation listed on the Openshift documentation pages](https://docs.openshift.com/container-platform/3.6/install_config/install/prerequisites.html) (for example ansible 2.3.0 or later is required for Openshift v3.6 installer and the NetworkManager package is required to be installed on the hosts)
9. Openshift Ansible installer must currently be executed in non-containerized mode when also installing Contiv (ie rpm based Openshift install). Support for the containerized Openshift install with Contiv will be an option in a future release.

**Important Note:**

1. The currently recommended combination is to use Openshift (Origin or Enterprise) version 3.6 or later and Contiv in L3 VXLAN mode without BGP. Earlier versions of Openshift or other networking modes of Contiv can also work but will require some additional manual configuration changes to the physical networking layer and/or the Openshift/ kubernetes layer. Note that the Openshift 3.6 Ansible installer can also be used to deploy Openshift packages from earlier releases by simply setting the openshift_release configuration variable in the ansible installer inventory file as shown in the examples below.  

## Installation example for Openshift + Contiv (L3 VXLAN mode use case)
In this example, we shall illustrate a single combined installation of Openshift and Contiv together and shall use Contiv in L3 VXLAN mode (which is currently the recommended mode for Contiv). This example deploys these on top of a cluster of Virtual Machines (that have been pre-created on some standard IaaS service such as Openstack for example) but this combination is also supported when the cluster hosts are bare metal machines.

1. Clone the standard Openshift Ansible repo directly from a supported release branch  
(*git clone -b release-3.6 https://github.com/openshift/openshift-ansible.git*)  
**Note:** Alternately the Openshift Ansible can also be installed via yum/ RPM (refer to Openshift documentation for details on using the *atomic-openshift-utils* rpm package for this)  or git cloned from the master branch, instead of the release-3.6 branch, from the same repo.
2. Edit the ansible inventory file to match the desired master and node topology and IP addresses of your target bare metal machines. The Openshift documentation (see for example [here](https://docs.openshift.org/latest/install_config/install/advanced_install.html) and [here](https://docs.openshift.com/container-platform/3.6/install_config/install/advanced_install.html)) has examples of Ansible inventory files for typical cluster deployments.
3. Edit the ansible inventory file to use Contiv as the networking plugin instead of the default Openshift SDN and set additional configuration parameters to match your cluster topology and contiv network settings. (an example of the Contiv configuration parameters is provided below).
4. Run the Ansible playbook for the BYO machines case  
*ansible-playbook -i your_inventory_file ./playbooks/BYO/config.yml*

## Example Ansible inventory file Openshift Origin + Contiv (L3 VXLAN mode) on VMs
Please refer to the [Openshift documentation](https://docs.openshift.org/latest/install_config/install/advanced_install.html) for full details on Openshift configuration. The example ansible inventory file here is to install a cluster of 3 Openshift Origin v3.6 nodes running Contiv in L3 VXLAN mode and deployed on top of 3 VMs. Each of these VMs has a private IP and a floating IP (in Openstack terminology). In the example below, the addresses in the range 184.94.x.x are the floating IP addresses of the cluster VMs and the addresses in the range 10.104.x.x are the private IP addresses of the cluster VMs. Please modify these to match the private IP and floating IP addresses in your set of VMs accordingly before running the playbook. 

```
# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=cloud

# Temporarily disable resource checks to allow test deployment on low resource hosts/ VMs 
openshift_disable_check=disk_availability,memory_availability,docker_storage

# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true

deployment_type=origin

# To try other release versions, change this variable (v3.6 is currently the recommended release)
#openshift_release=v1.5
openshift_release=v3.6

os_firewall_use_firewalld=false

openshift_use_openshift_sdn=False
openshift_use_contiv=True
os_sdn_network_plugin_name='cni'

# Use the following contiv settings for now. 
# In upcoming versions of the installer, these settings will be automatically defaulted and hence not needed to be configured explicitly here
netplugin_interface=eth0
netmaster_interface=eth0
netplugin_fwd_mode=routing
contiv_encap_mode=vxlan
contiv_default_network_tag=1000

# host group for masters
[masters]
184.94.251.61 openshift_public_hostname=184.94.251.61

# host group for nodes, includes region info
[nodes]
184.94.251.61 netplugin_ctrl_ip=10.104.1.80 openshift_public_hostname=184.94.251.61 openshift_node_labels="{'region': 'infra', 'zone': 'default'}" openshift_schedulable=true
184.94.253.153 netplugin_ctrl_ip=10.104.1.83 openshift_public_hostname=184.94.253.153 openshift_node_labels="{'region': 'primary', 'zone': 'east'}" openshift_schedulable=true
184.94.251.16 netplugin_ctrl_ip=10.104.1.84 openshift_public_hostname=184.94.251.16 openshift_node_labels="{'region': 'primary', 'zone': 'west'}" openshift_schedulable=true
```

## Cleaning up/ uninstalling an Openshift + Contiv cluster

You may sometimes need to do a clean rebuild of an Openshift + Contiv cluster. This may be because of an error in a prior deployment attempt that may have left some unknown/ partial state on the host machines or when you are switching from another network plugin type to Contiv for example. In all such cases, it is strongly recommended 
clean up the cluster hosts and remove any left over state that may exist on the hosts. Without proper cleanup/ uninstall of prior state, it is possible to have errors in new attempts to deploy Openshift + Contiv on the same hosts. In order to uninstall Contiv and Openshift, run the following two ansible playbooks

1. *ansible-playbook -i your_inventory_file ./playbooks/adhoc/contiv/delete_contiv.yml*
2. *ansible-playbook -i your_inventory_file ./playbooks/adhoc/uninstall.yml*

After these steps, the hosts will be cleaned up from any left over state and a new Openshift + Contiv cluster may safely be installed on these hosts using an install process such as described in the earlier example. 

## Installation example for Openshift + Contiv (L2 VLAN mode use case)

In this second example, we shall illustrate a single combined installation of Openshift and Contiv together and shall use the Openshift Ansible directly from github to do this. In this example, we have an Ansible installer/ management node installing Openshift + Contiv onto 4 bare metal servers resulting in 1 Master + 3 Nodes in the resulting Openshift cluster. 

1. Clone the standard Openshift Ansible repo directly (*git clone https://github.com/openshift/openshift-ansible.git*)
2. Edit the ansible inventory file to match the desired master and node topology and IP addresses of your target bare metal machines. The Openshift documentation (see for example [here](https://docs.openshift.org/latest/install_config/install/advanced_install.html) and [here](https://docs.openshift.com/container-platform/3.6/install_config/install/advanced_install.html)) has examples of Ansible inventory files for typical cluster deployments.
3. Edit the ansible inventory file to use Contiv as the networking plugin instead of the default Openshift SDN and set additional configuration parameters to match your cluster topology and contiv network settings. (an example of the Contiv configuration parameters is in the following section).
4. Run the Ansible playbook for the BYO machines case  
*ansible-playbook -i your_inventory_file ./playbooks/BYO/config.yml*

Thats it, you now have a running Openshift cluster which uses Contiv as its networking layer.

## Example Ansible inventory file for deploying Openshift Origin + Contiv (L2 VLAN mode) on Bare Metal servers

Please refer to the [Openshift documentation](https://docs.openshift.org/latest/install_config/install/advanced_install.html) for full details on Openshift configuration. Here we list an example of adapting one of the inventory files from the Openshift documentation examples to substitute Contiv in place of the default Openshift SDN. This example illustrates set up for an Openshift Origin cluster running version 3.6. Contiv is enabled via the variable "openshift_use_contiv" and by setting "openshift_use_openshift_sdn" to "false" as well as other parameters as shown below. "netplugin_interface" is the contiv data plane vlan interface, "netmaster_interface" is the control plane interface, "netplugin_fwd_interface" set to "bridge" sets Contiv in L2 vlan mode. The default subnet (for pod IPs), default gateway and VLAN tag are set via  "contiv_default_subnet", "contiv_default_gw" and "contiv_default_network_tag".  When this playbook is executed, a default container network (called "default-net") will also be set up and will use these parameters. Note that since this is the L2 VLAN mode of Contiv, the data plane VLANs and default gateway will also need to be setup externally in the physical network that the cluster uses. 

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

openshift_release=v3.6

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

# rest of the file similar to the example listed above for the L3 VXLAN mode case
```

