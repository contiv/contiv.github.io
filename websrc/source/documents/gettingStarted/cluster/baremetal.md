---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "getting-started-cluster-baremetal"
description: |-
  Getting Started
---

##Contiv Cluster Installation on Baremetal Server or VM

This document goes through the steps to install Contiv Cluster to a baremetal server

**Note:**
- Unless explicitly mentioned all the steps below are done by logging into the same host. It is referred as *control host* below.
- Validation of these steps have been done on RHEL 7.2 and CentOS 7.2. More OS variations will be added in future.

### pre-requisites
- ansible 2.0 or higher is installed.
- git is installed.
- a management user has been created. Let's call that user **cluster-admin** from now on.
  - note that `cluster-admin` can be an existing user.
  - this user needs to have **passwordless sudo** access configured. You can use `visudo` tool for this.
- a ssh key has been generated for `cluster-admin`. You can use `ssh-keygen` tool for this.
- the public key for `cluster-admin` user is added to all the hosts(including the control host) in your setup. You can use `ssh-copy-id cluster-admin@<hostname>` for this, where `<hostname>` is name of the host in your setup where `cluster-admin` is being added as authorized user.

###1. Download and install Cluster Manager
```
# Login as `cluster-admin` user before running following commands
git clone https://github.com/contiv/ansible.git
cd ansible

# Create an inventory file
echo [cluster-control] > /tmp/hosts
echo node1 ansible_host=127.0.0.1 >> /tmp/hosts

# Install Cluster Manager service
ansible-playbook --key-file=~/.ssh/id_rsa -i /tmp/hosts -e '{"env": {}, "control_interface": "ifname"}' ./site.yml
```

**Note**:
- `env` and `control_interface` need to be specified.
- `env` is used to specify the environment for running ansible tasks like http-proxy. If there is no special environment to be setup then it needs to be set to an empty dictionary as shown in the example above.
- `control_interface` is the netdevice that will carry serf traffic on this node.

###2. Configure the cluster manager service
Edit the cluster manager configuration file that is created at `/etc/default/clusterm/clusterm.conf` to setup the user and playbook-location information. A sample is shown below. `playbook-location` needs to be set as the path of ansible directory we cloned in previous step. `user` needs to be set as name of `cluster-admin` user and `priv_key_file` is the location of the `id_rsa` file of `cluster-admin` user.

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
After the changes look good, restart cluster manager

```
sudo systemctl restart clusterm
```

## Node Life-Cycle management

### login to the first node to manage the cluster

**Note:** The first node is slightly special in a way that it is booted up with two additional services viz. `collins` and `clusterm`. `collins` is used as the node lifecycle management and event logging service. `clusterm` is the cluster manager daemon. `clusterctl` utility is provided to exercise cluster manager provided REST endpoint.

### Provision additional nodes for the cluster formation through discovery

```
clusterctl discover <host-ip(s)>
```
Cluster Manager uses Serf as a discovery service for node health monitoring and for cluster bootstrapping. Use `discover` command to include additional nodes in the discovery service. The `<host-ip>` should be an IP address from a management network only used by infra services such as serf, etcd, swarm, etc..

**Note**:

```
clusterctl discover 192.168.2.11 192.168.2.12 --extra-vars='{"env" : {}, "control_interface": "eth1" }'
```
- The command above will provision the other two vms (viz. cluster-node2 and cluster-node3) in the vagrant setup for serf based discovery. Once it is run, the discovered hosts will appear in `clusterctl nodes get` output in a few minutes.
- the `clusterctl discover` command expects `env` and `control_interface` ansible variables to be specified. This can be achieved by using the `--extra-vars` flag as shown above or by setting them at [global level](#setget-global-variables), if applicable. For more information on other available variables, also checkout [discovery section of ansible vars](ansible_vars.md#serf-based-discovery)

### Get list of discovered nodes
```
clusterctl nodes get
```

And info for a single node can be fetched by using `clusterctl node get <node-name>`.

### Set/Get global variables
```
clusterctl global set --extra-vars=<vars>
```
A common set of variables (like environment, scheduler-provider and so on) can be set just once using the `--extra-vars` flag with `clusterctl global set` command.

**Note**:
- The variables need to be passed as a quoted JSON string using the `--extra-vars` flag.

```
clusterctl global set --extra-vars='{"env" : {"http_proxy": "my.proxy.url"}, "scheduler_provider": "ucp-swarm"}'
```
- The variables set at global level are merged with the variables specified at the node level, with the latter taking precedence in case of an overlap/conflict.
- The list of useful variables is provided at the end of this document at here.

### Commission a node
```
clusterctl node commission <node-name> --host-group=<service-master|service-worker>
```

Commissioning a node involves pushing the configuration and starting infra services on that node using `ansible` based configuration management. The services that are configured depend on the mandatory parameter `--host-group`. Checkout the `service-master` and `service-worker` host-groups in [ansible/site.yml](../vendor/ansible/site.yml) to learn more about the services that are configured. To quickly check if commissioning a node worked, you can run `etcdctl member list` on the node. It shall list all the commissioned members in the list.

**Note**:
- certain ansible variables need to be set for provisioning a node. The list of mandatory and other useful variables is provided in [ansible_vars.md](./ansible_vars.md). The variables need to be passed as a quoted JSON string in node commission command using the `--extra-vars` flag.

```
clusterctl node commission node1 --extra-vars='{"env" : {}, "control_interface": "eth1", "netplugin_if": "eth2" }' --host-group "service-master"
```
- a common set of variables (like environment) can be set just once as [global variables](#setget-global-variables). This eliminates the need to specify the common variables for every commission command.

### Decommission a node
```
clusterctl node decommission <node-name>
```

Decommissioning a node involves stopping and cleaning the configuration for infra services on that node using `ansible` based configuration management.

### Perform an upgrade
```
clusterctl node maintain <node-name>
```

Upgrading a node involves upgrading the configuration for infra services on that node using `ansible` based configuration management.

### Get provisioning job status
```
clusterctl job get <active|last>
```
Common cluster management workflows like commission, decommission and so on involve running an ansible playbook. Each such run per workflow is referred to as a job. You can see the status of an ongoing (active) or last run job using this command.

### Managing multiple nodes
```
clusterctl nodes commission <space separated node-name(s)>
clusterctl nodes decommission <space separated node-name(s)>
clusterctl nodes maintain <space separated node-name(s)>
```

The worflow to commission, decommission or upgrade all or a subset of nodes can be performed by using `clusterctl nodes` subcommands. Please refer the documentation of individual commands above for details.


### Ansible variables used during provisioning

This file lists the ansible variables that can be passed at the time of commissioning a node or at a global level as described in [README.md](./README.md#setget-global-variables). The ansible variables can also be passed at the time of setting up a node for discovery as described in [baremetal.md](./baremetal.md#3-provision-rest-of-the-nodes-for-discovery-from-the-control-host). The variables specified at global level are merged with variables specified for a node level operation, with latter taking precedence over the former in case of a overlap/conflict.

Setting the variable at a global level that has same value across all nodes in a cluster, can substantially reduce the amount of variables that need to specified at every node level operation and is a recommended way to set the variables when possible.

The rest of this document is split into two sections viz. [*Mandatory variables*]() and [*Commonly used variables*](). *Mandatory variables* lists the variables that must be set before a node can be configured. *Commonly used variables* lists the variables that we would use to affect the default ansible behavior like deploying a specific scheduler stack or a specific networking mode.

*Commonly used variables* are further organized into following service specific sub-sections:
- [Serf based Discovery](#serf-based-discovery)
- [Scheduler stack](#scheduler-stack)
- [Contiv Networking](#contiv-networking)
- [Contiv Storage](#contiv-storage)

There are several variables that are made available to provide a good level of programmability in the ansible plays and the reader is encouraged to look at the plays in [vendor/ansible](../vendor/ansible)

### Mandatory variables
- **env** is used to set the environment variables that need to be available to ansible tasks. A common usecase of this variable is to set the http-proxy info.
- **env** is specified as a JSON dictionary.

```
{"env": { "var1": "val1", "http_proxy": "http://my.proxy.url", "https_proxy": "http://my.proxy.url" }}
```
- It should be set to empty dictionary if no environment variables needs to be set.
```
{"env": {}}

```
- **control_interface** identifies the netdevice on the node that will carry the traffic generated by infrastructure applications like etcd, ceph and so on.
- **control_interface** is specified as a JSON string

```
{"control_interface": "eth1"}
```
- **netplugin_if** identifies the netdevice on the node that will carry the data traffic generated by the containers networked using contiv data plane.
- **netplugin_if** is specified as a JSON string

```
{"netplugin_if": "eth2"}
```
- **service_vip** identifies an available static IP address that can be used as a virtual ip to provide reachability for contiv services.
- **service_vip** is specified as a JSON string

```
{"service_vip": "192.168.2.252"}
```

### Optional/Commonly used variables

#### Serf based Discovery
- **serf_cluster_name** identifies the name of the cluster that serf uses to discover other peer nodes. You may use this if there are multiple clusters in the same subnet of `control_interface` and you would like serf to only discover the nodes in a specific cluster.
- **serf_cluster_name** is specified as a JSON string

```
{"serf_cluster_name": "cluster-prod-eng"}
```

#### Scheduler stack
- **scheduler_provider** identifies the scheduler stack to use. We support two stacks viz. `native-swarm` and `ucp-swarm`. The first brings-up a swarm cluster using the stock swarm image from dockerhub. The seconds brings-up a ucp cluster which bundles swarm in it.
- **scheduler_provider** is specified as a JSON string

```
{"scheduler_provider": "ucp-swarm"}
```
- **ucp_bootstrap_node_name** identifies the name (as seen in `clusterctl nodes get` command) of the node to bootstrap ucp with. This is the first node that is commissioned in the cluster. This is mandatory when **scheduler_provider** was set to `ucp-swarm`
- **ucp_bootstrap_node_name** is specified as a JSON string

```
{"ucp_bootstrap_node_name": "cluster-node1-0"}
```
- **ucp_license_file** identifies the path to UCP license file on the host where ansible is run. This can be used to pass the UCP license at the time of configuring UCP cluster.
- **ucp_license_file** is specified as a JSON string
```
{"ucp_license_file": "/path/to/ucp/licence"}
```

#### Contiv Networking
- **contiv_network_mode** identifies the mode of operation for netplugin. Netplugin supports two modes viz. `aci` and `standalone`. The first is used to bring-up netplugin in a Cisco APIC managed fabric deployment, while the second mode can be used when deploying netplugin with standalone Layer2/Layer3 switches.
- **contiv_network_mode** is specified as a JSON string

```
{"contiv_network_mode": "aci"}
```

**Following are the relevant variables when `contiv_network_mode` is set to `aci`**
- **apic_url** specifies the url for APIC. This is a mandatory variable in aci mode.
- **apic_url** is specified as a JSON string

```
{"apic_url": "https://<apic-server-url>:443"}
```
- **apic_username** specifies the username for APIC. This is a mandatory variable in aci mode.
- **apic_username** is specified as a JSON string

```
{"apic_username": "my-user"}
```
- **apic_password** specifies the password for APIC. This is a mandatory variable in aci mode.
- **apic_password** is specified as a JSON string

```
{"apic_password": "my-password"}
```
- **apic_leaf_nodes** specifies full path of the leaf nodes connected managed by APIC. This is a mandatory variable in aci mode.
- **apic_leaf_nodes** is specified as a JSON string

```
{"apic_leaf_nodes": "topology/pod-1/node-101,topology/pod-1/node-102"}
```
- **apic_phys_domain** specifies the name of the physical domain name created in APIC.
- **apic_phys_domain** is specified as a JSON string

```
{"apic_phys_domain": "allVlans"}
```
- **apic_epg_bridge_domain** can be optionally used to provide a pre-created bridge domain. The bridge domain should have  already been created under tenant `common`.
- **apic_epg_bridge_domain** is specified as a JSON string

```
{"apic_epg_bridge_domain": "my-bd"}
```
- **apic_contracts_unrestricted_mode** can be optionally used to allow unrestricted communication between EPGs.
- **apic_contracts_unrestricted_mode** is specified as a JSON string

```
{"apic_contracts_unrestricted_mode": "yes"}
```

**Following are the relevant variables when `contiv_network_mode` is set to `standalone`**
- **fwd_mode** specifies whether netplugin shall bridge or route the packet. Netplugin supports two forwarding modes viz. `bridge` and `routing`.
- **fwd_mode** is specified as a JSON string

```
{"fwd_mode": "routing"}
```

#### Contiv Storage
**TBD**
