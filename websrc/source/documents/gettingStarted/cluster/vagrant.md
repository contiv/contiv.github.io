---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "getting-started-cluster-vagrant"
description: |-
  Getting Started
---

# Getting Started with Contiv Cluster

For Contiv Cluster manager with baremetal hosts or a multiple VMs, see  [Installing Contiv Cluster on a Baremetal Server or VM](baremetal.html) to set up the hosts.

To quickly create a virtual environment using the Vagrant environment setup tool, do the following:

## Prerequisites
Install the following packages on your machnine:

- Vagrant 1.7.3 or later
- VirtualBox 5.0 or later
- Ansible 2.0 or later
- Go 1.6 or later

## Step 1. Check Out the Project
Use the following commands to clone the project to your machine:

```
cd $GOPATH/src/github.com/contiv/
git clone https://github.com/contiv/cluster.git
```

## Step 2. Launch Three Vagrant Nodes
Use the following commands to launch three nodes in the Vagrant environment:

```
cd cluster/
CONTIV_NODES=3 make demo-cluster
```

*Note:* The project's `Vagrantfile` configures all the vagrant nodes (except for the first node) to boot up with a stock Centos7.2 OS and with a `serf` agent running. The `serf` agent is used as the node's discovery service. This configuration is intended to make management easier by limiting the number of services needed to start a cluster.

## Step 3. Log In to the First Node
The first node is is booted with two additional services, `collins` and `clusterm`. The `collins` service serves as the node lifecycle management and event logging service. The `clusterm` service is the cluster manager daemon. 

You use the `clusterctl` utility exercise the cluster manager's REST endpoint.

Use the following command to log into the first node:

```
CONTIV_NODES=3 vagrant ssh cluster-node1
```

## What to Do Next

See the [Cluster](/documents/cluster/node-lifecycle.html) docuentation for information about managing the cluster lifecycle.
