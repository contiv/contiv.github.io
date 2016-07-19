---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "getting-started-cluster-baremetal"
description: |-
  Getting Started
---

# Installing Contiv Cluster on a Baremetal Server or VM

This page describes installing Contiv Cluster on one or more baremetal servers or virtual machines (VMs).

*Note:* These steps have been validated on RHEL 7.2 and CentOS 7.2.

## Prerequisites
Do the following before installing the Contiv Cluster packages:

- Choose one of the nodes in your cluster from which to perform the installation. The resto of these instructions refer to this node as the *control host*. 
Unless stated otherwise, all the steps below are performed on the control host.
- Create a user with admin privileges on the control host. The rest of these instructions refer to this login as *cluster-admin*.
  - The *cluster-admin* login can be an existing login.
  - The *cluster-admin* login must have *passwordless sudo* access configured. You can use the `visudo` tool to configure passwordless access.
- Generate an *ssh* key for *cluster-admin*. You can use the `ssh-keygen` tool to generate an *ssh* key.
- Add the public key for *cluster-admin* to all the nodes (including the control node) in your setup. 
You can use `ssh-copy-id cluster-admin@<hostname>` on each node, where `<hostname>` is the name of your control node.

Install the following packages on your control host.

- Ansible 2.0 or later
- Git

## Installing the Cluster Manager

### Step 1. Download and Install Cluster Manager
Log into your control node as *cluster-admin*, then use the following commands to:

1\. Download Ansible

2\. Create an inventory file called `hosts` in the `tmp` directory

3\. Install the cluster manager service

```
git clone https://github.com/contiv/ansible.git
cd ansible

echo [cluster-control] > /tmp/hosts
echo node1 ansible_host=127.0.0.1 >> /tmp/hosts

ansible-playbook --key-file=~/.ssh/id_rsa -i /tmp/hosts -e '{"env": {}, "control_interface": "ifname"}' ./site.yml
```

- The `control_interface` is the net device that carries *Serf* traffic on this node. Subtitute the interface name for `ifname`.
- The `env` is the environment for running Ansible tasks such as `http-proxy`. 

If there is no special environment to be configured then set `control_interface` to an empty dictionary as shown in the example.

### Step 2. Configure the Cluster Manager Service
Edit the cluster manager configuration file `/etc/default/clusterm/clusterm.conf` to set up the user and playbook location information. 
Following is a sample. 

```
# cat /etc/default/clusterm/clusterm.conf
{
    "ansible": {
        "playbook_location": "/home/cluster-admin/ansible/",
        "user": "cluster-admin",
        "priv_key_file": "/home/cluster-admin/.ssh/id_rsa"
    }
}
```

- The `playbook-location` must contain the path of th Ansible directory you cloned 
- The `user` must contain the name of the *cluster-admin* user 
- The `priv_key_file` value is the location of the `id_rsa` file of the `cluster-admin` user

After you have made the changes, restart the control host:

```
sudo systemctl restart clusterm
```

## Managing Node Lifecycle

Log into the control host to manage the cluster.

*Note:* The control host has two additional services that are not on other nodes, `collins` and `clusterm`. 

- The `collins` service is for node lifecycle management and event logging. 
- The `clusterm` service is the cluster manager daemon. The `clusterctl` utility is provided to exercise the REST endpoint provided by the cluster manager.

<a name="provisioning"></a>
### Provision Additional Nodes 
Cluster Manager uses *Serf* as a discovery service for node health monitoring and for cluster bootstrapping. 

Use the following command to make more nodes for the cluster availble through discovery:

```
clusterctl discover <host-ip>
```

The `<host-ip>` should be one or more IP addresses from the management network that the nodes are on.
The management network is used only by infrastructure services such as *serf*, *etcd*, *swarm*, and so on.

The following command provisions the other two VMs (`cluster-node2` and `cluster-node3`) 
in the Vagrant setup for *Serf*-based discovery: 

```
clusterctl discover 192.168.2.11 192.168.2.12 --extra-vars='{"env" : {}, "control_interface": "eth1" }'
```  
  
You must specify the `env` and `control_interface` Ansible variables. Do this by using the 
`--extra-vars` flag as shown. 

You can also set variables as [global variables].

For more information on Ansible variables, see the list of [Ansible Variables].


### List Discovered Nodes

Use the following command to view the cluster nodes:

```
clusterctl nodes get
```

*Note*: It takes a few minutes for the nodes to be discovered and to appear in the list.

To fetch information about a single node use:
```clusterctl node get <node-name>```.

<a name="set_get_global_vars"></a>
### Set and Get Global Variables

You can set variables common to all cluster nodes (for example,  environment, scheduler-provider and so on) 
by using the 
`--extra-vars` flag with `clusterctl global set` command, as follows:

```
clusterctl global set --extra-vars=<vars>
```

Note the following: 

- The variables set at global level are merged with the variables specified at the node level. In case of a conflict, the node-level variable takes precedence.
- See [Ansible Variables] for a list of applicable variables.
- The variables must be passed as a quoted JSON string using the `--extra-vars` flag. For example:

```
clusterctl global set --extra-vars='{"env" : {"http_proxy": "my.proxy.url"}, "scheduler_provider": "ucp-swarm"}'
```

### Commission a Node
To commission a node, use the following command:

```
clusterctl node commission <node-name> --host-group=<service-master|service-worker>
```

The command pushes the configuration to the node and starts infra services on that node using `ansible`-based configuration management. 

The services that are configured depend on the mandatory parameter `--host-group`. 

See the `service-master` and `service-worker` host-groups in [ansible/site.yml] to learn more about the services that are configured. 

To quickly check if commissioning a node worked, use: 

```etcdctl member list```

The command lists all the commissioned members of the list.

Some Ansible variables are mandatory when commissioning a node. Mandatory variables, as well as some useful optional variables, are listed at [Ansible Variables].

The variables must be passed as a quoted JSON string using the `--extra-vars` flag. For example:

```
clusterctl node commission node1 --extra-vars='{"env" : {}, "control_interface": "eth1", "netplugin_if": "eth2" }' --host-group "service-master"
```

A common set of variables (for example, environment variables) can be set just once as [global variables].
This eliminates the need to specify the common variables for every commission command.

### Decommission a Node
Use the following command to decommission a node:

```
clusterctl node decommission <node-name>
```

The command stops and removes the infra services on that node using `ansible`-based configuration management.

### Perform an Upgrade
Use the following command to upgrade a node:

```
clusterctl node maintain <node-name>
```

The command upgrades the configuration for infra services on that node using `ansible`-based configuration management.

### Get Provisioning Job Status
Use the following command to examine the status of another provisioning command:

```
clusterctl job get <active|last>
```

Cluster management workflows, including commission, decommission and so on, involve running an Ansible playbook. 
Each such workflow run is referred to as a job. You can see the status of an active job or of the last run job using this command.

### Managing Multiple Nodes
To perform a workflow on all nodes, or a subset of nodes, in a cluster, use the `clusterctl nodes` command as follows:

```
clusterctl nodes commission <space-separated node-names>
clusterctl nodes decommission <space-separated node-names>
clusterctl nodes maintain <space-separated node-names>
```

Refer the documentation of individual commands for details about the commands' effects.

<a name="ansible_vars"></a>
## Ansible Variables for Provisioning
Following is a list of the Ansible variables that can be passed when commissioning a node, or set at a global level as described in [Set and Get Global Variables].

Ansible variables can also be passed at the time of setting up a node for discovery as described in [Provisioning Additional Nodes].

Variables specified at the global level are merged with variables specified for a node-level operation. In case of a conflict, the node-level variable takes precedence.

Setting a global variable that has same value across all nodes in a cluster can substantially reduce the need to specified variables at every node-level operation,
 and is a recommended practice.

The lists of Variables that follow are in sections, [*Mandatory Variables*] and [*Optional Variables*]. (The Optional Variables list is not comprehensive, but contains variables useful for clustering tasks.)

*Mandatory Variables* are variables that must be set before a node can be configured. 

*Optional Variables* are variables that affect the default Ansible behavior. Examples are deploying a specific scheduler stack or a specific networking mode.

*Optional Variables* are further organized into the following service-specific subsections:

- [Serf-based Discovery]
- [Scheduler Stack]
- [Contiv Networking]

Several other variables are made available to provide a programmability in the Ansible plays. We encourage you to look at the 
Ansible plays on the [Contiv Cluster GitHub site].

<a name="mandatory_vars"></a>
### Mandatory Variables

- `env` is used to set the environment variables available to Ansible tasks. A common use of this variable is to set the http-proxy information.
- `env` is specified as a JSON dictionary.

```
{"env": { "var1": "val1", "http_proxy": "http://my.proxy.url", "https_proxy": "http://my.proxy.url" }}
```

- **env** should be set to an empty dictionary if no environment variables need to be set.

```
{"env": {}}
```

- **control_interface** identifies the netdevice on the node that carries the traffic generated by infrastructure applications like `etcd`, `ceph` and so on.
- **control_interface** is specified as a JSON string.

```
{"control_interface": "eth1"}
```

- **netplugin_if** identifies the netdevice on the node that carries the data traffic generated by the containers networked using the Contiv data plane.
- **netplugin_if** is specified as a JSON string.

```
{"netplugin_if": "eth2"}
```

- **service_vip** identifies a static IP address that can be used as a virtual IP to access Contiv services.
- **service_vip** is specified as a JSON string.

```
{"service_vip": "192.168.2.252"}
```

<a name="optional_vars"></a>
### Optional Variables

<a name="serf-based-discovery"></a>
#### Serf-based Discovery

- **serf_cluster_name** is the name of the cluster that Serf uses to discover other peer nodes. You can use this if there are multiple clusters in the same subnet of `control_interface` and you would like Serf to only discover the nodes in a specific cluster.
- **serf_cluster_name** is specified as a JSON string.

```
{"serf_cluster_name": "cluster-prod-eng"}
```

<a name="scheduler-stack"></a>
#### Scheduler Stack

- **scheduler_provider** identifies the scheduler stack to use. Two stacks are supported: `native-swarm` and `ucp-swarm`. The first creates a swarm cluster using the stock swarm image from Docker Hub. The seconds brings-up a UDP cluster with swarm bundled in it.
- **scheduler_provider** is specified as a JSON string.

```
{"scheduler_provider": "ucp-swarm"}
```

- **ucp_bootstrap_node_name** is the name (as seen in the `clusterctl nodes get` command) of the node to bootstrap UCP with. This is the first node that is commissioned in the cluster. This variable is mandatory when **scheduler_provider** is set to `ucp-swarm`.
- **ucp_bootstrap_node_name** is specified as a JSON string.

```
{"ucp_bootstrap_node_name": "cluster-node1-0"}
```

- **ucp_license_file** identifies the path to the UCP license file on the host where Ansible is run. This variable can be used to pass the UCP license at the time of configuring a UCP cluster.
- **ucp_license_file** is specified as a JSON string.

```
{"ucp_license_file": "/path/to/ucp/licence"}
```

<a name="contiv-networking"></a>
#### Contiv Networking

- **contiv_network_mode** identifies the mode of operation for `netplugin`. Netplugin supports two modes: `aci` and `standalone`. `aci` mode is used to start `netplugin` in a Cisco APIC managed fabric deployment. 'standalone' mode can be used when deploying `netplugin` with standalone layer2 and layer3 switches.
- **contiv_network_mode** is specified as a JSON string.

```
{"contiv_network_mode": "aci"}
```

##### ACI Mode
The following variables are applicable when `contiv_network_mode` is set to `aci`:

- **apic_url** specifies the URL for APIC. This is a mandatory variable in `aci` mode.
- **apic_url** is specified as a JSON string.

```
{"apic_url": "https://<apic-server-url>:443"}
```

- **apic_username** specifies the username for APIC. This is a mandatory variable in `aci` mode.
- **apic_username** is specified as a JSON string.

```
{"apic_username": "my-user"}
```

- **apic_password** specifies the password for APIC. This is a mandatory variable in `aci`  mode.
- **apic_password** is specified as a JSON string.

```
{"apic_password": "my-password"}
```

- **apic_leaf_nodes** specifies the full path of the leaf nodes managed by APIC. This is a mandatory variable in `aci` mode.
- **apic_leaf_nodes** is specified as a JSON string.

```
{"apic_leaf_nodes": "topology/pod-1/node-101,topology/pod-1/node-102"}
```

- **apic_phys_domain** specifies the name of the physical domain name created in APIC.
- **apic_phys_domain** is specified as a JSON string.

```
{"apic_phys_domain": "allVlans"}
```

- **apic_epg_bridge_domain** can be optionally used to provide a pre-created bridge domain. The bridge domain must already exist under tenant `common`.
- **apic_epg_bridge_domain** is specified as a JSON string.

```
{"apic_epg_bridge_domain": "my-bd"}
```

- **apic_contracts_unrestricted_mode** can optionally be used to allow unrestricted communication between EPGs.
- **apic_contracts_unrestricted_mode** is specified as a JSON string.

```
{"apic_contracts_unrestricted_mode": "yes"}
```

##### Standalone Mode
The following variables are applicable when `contiv_network_mode` is set to `standalone`:

- **fwd_mode** specifies whether netplugin shall bridge or route the packet. Netplugin supports two forwarding modes viz. `bridge` and `routing`.
- **fwd_mode** is specified as a JSON string.

```
{"fwd_mode": "routing"}
```

[Ansible Variables]: <#ansible_vars>
[ansible/site.yml]: </extras/site.yml>
[global variables]: <#set_get_global_vars>
[Set and Get Global Variables]: <#set_get_global_vars>
[Provisioning Additional Nodes]: <#provisioning>
[*Mandatory Variables*]: <#mandatory_vars>
[*Optional Variables*]: <#optional_vars>
[Serf-based Discovery]: <#serf-based-discovery>
[Scheduler Stack]: <#scheduler-stack>
[Contiv Networking]: <#contiv-networking>
[Contiv Cluster GitHub site]: <https://github.com/contiv/cluster/tree/master/vendor/ansible>
