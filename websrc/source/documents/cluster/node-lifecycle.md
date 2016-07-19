---
layout: "documents"
page_title: "Cluster"
sidebar_current: "cluster-node-lifecycle"
description: |-
  Cluster
---


# Node Lifecycle Management

To set up a cluster with baremetal or VM hosts see [Installing Contiv Cluster on a Baremetal Server or VM](/documents/gettingStarted/cluster/baremetal.html). To configure cluster management after setup, start with Step 3 below.

To set up Contiv Cluster on a development machine using Vagrant, follow all the steps below.

### Prerequisites
Install the following packages on your machine:

- Vagrant 1.7.3 or later
- Virtualbox 5.0 or later
- Ansible 2.0 or later

### Step 1. Check Out and Build the Project
Check out and build the project's code as follows:

```
cd $GOPATH/src/github.com/contiv/
git clone https://github.com/contiv/cluster.git
```

### Step 2. Launch Nodes
Launch three Vagrant nodes using the following commands.

*Note:* As configured in the project's `Vagrantfile`, all Vagrant nodes except the first node boot up with stock *centos7.2* OS and a `serf` agent running. The `serf` service is used as the node discovery service. This configuration limits the number of services needed to start a cluster. 

```
cd cluster/
CONTIV_NODES=3 make demo-cluster
```

### 3. Log In

*Note:* The first node is booted with two additional services, `collins` and `clusterm`. The `collins` service is used for node lifecycle management and event logging. The `clusterm` service is the cluster manager daemon. A `clusterctl` utility is provided to exercise the cluster manager's REST API.

Log in to the first node to manage the cluster:

```
CONTIV_NODES=3 vagrant ssh cluster-node1
```

#### Provision Nodes
Provision more nodes for discovery:

```
clusterctl discover <host-ips>
```
Cluster Manager uses Serf as a discovery service for node health monitoring and for cluster bootstrapping. Use the `discover` command to add nodes to the discovery service. The `<host-ips>` are a list of IP addresses from a management network used only by infra services such as `serf`, `etcd`, `swarm`, and so on.

The following command provisions the other two VMs (cluster-node2 and cluster-node3) in the Vagrant setup for Serf-based discovery. After a few minutes, discovered hosts appear in `clusterctl nodes get` output (the command requires a few minutes to propagate).

```
clusterctl discover 192.168.2.11 192.168.2.12 --extra-vars='{"env" : {}, "control_interface": "eth1" }'
```

*Note*:
You must specify the `env` and `control_interface` Ansible variables in the `clusterctl discover` command.
Specify these variables in one of two ways: 

- Use the `--extra-vars` flag as shown above 
- Set the variables as [global level variables](#setget_global_vars), if applicable. 

For information on other available variables, see the discovery section of [Ansible Variables] in the Contiv Cluster GitHub repository.

#### List Nodes
The following command lists discovered nodes:

```
clusterctl nodes get
```

Fetch information about a single node with the following commnand: 
```clusterctl node get <node-name>```

It might take a few minutes after provisioning for the node discovery to propagate. If the command does not show provisioned nodes, wait and try again later.

#### Commission a Node
Commissioning a node pushes the configuration and starts infra services on that node using `ansible` based configuration management. The services that are configured depend on the mandatory parameter `--host-group`. 

```
clusterctl node commission <node-name> --host-group=<service-master|service-worker>
```

See the `service-master` and `service-worker` host groups in [ansible/site.yml](/extras/site.yml) to learn more about the services that are configured. To quickly check if commissioning a node worked, run `etcdctl member list` on the node. The command lists all the commissioned members.

*Note*: Some Ansible variables must be set to provision a node. See the list of mandatory variables, as well as other useful variables, in the discussion of [Ansible Variables] in the Contiv Cluster GitHub repository. The variables must be passed as a quoted JSON string in the node commission command using the `--extra-vars` flag:

```
clusterctl node commission node1 --extra-vars='{"env" : {}, "control_interface": "eth1", "netplugin_if": "eth2" }' --host-group "service-master"
```

You can eliminate the need to set global variables with every commission command by directly setting [global level variables].

#### Decommission a Node
Decommissioning a node stops infra services and removes the configuration from the node using `ansible` based configuration management.

```
clusterctl node decommission <node-name>
```

#### Perform an Upgrade
Upgrading a node upgrades the configuration for infra services on that node using `ansible` based configuration management.

```
clusterctl node maintain <node-name>
```

<a name="setget_global_vars"></a>
#### Set and Get Global Variables
Configure common variables (environment, scheduler-provider, and so on) just once using the `--extra-vars` flag with the `clusterctl global set` command:

```
clusterctl global set --extra-vars=<vars>
```

*Note*: Pass the variables as a quoted JSON string using the `--extra-vars` flag:

```
clusterctl global set --extra-vars='{"env" : {"http_proxy": "my.proxy.url"}, "scheduler_provider": "ucp-swarm"}'
```

- The variables set at the global level are merged with the variables specified at the node level. In case of overlap, node-level variables take precedence.
- The list of variables is provided in the [Ansible Variables] document in the Contiv Cluster GitHub repository.

#### Get Job Status
Common cluster management workflows like commission, decommission and so on work by running an Ansible playbook. Each such run per workflow is referred to as a job. You can see the status of an ongoing (active) or last-run job using this command:

```
clusterctl job get <active|last>
```

#### Manage Multiple Nodes
Perform the worflow to commission, decommission, or upgrade all or a subset of nodes using `clusterctl nodes` subcommands. Refer the documentation of individual commands for details.

```
clusterctl nodes commission <space separated node-name(s)>
clusterctl nodes decommission <space separated node-name(s)>
clusterctl nodes maintain <space separated node-name(s)>
```

[Ansible Variables]: <https://github.com/contiv/cluster/blob/master/management/ansible_vars.md>
[global level variables]: <#setget_global_vars>
