---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "getting-started-cluster-vagrant"
description: |-
  Getting Started
---

## 3 steps to Contiv Cluster Management

If you are trying cluster manager with baremetal hosts or a personal VM setup follow [this link](baremetal.html) to setup the hosts. After that you can manage the cluster as described in the step 3. below.

To try with a built-in vagrant based VM environment continue reading.

### 0. Ensure correct dependencies are installed
- vagrant 1.7.3 or higher
- virtualbox 5.0 or higher
- ansible 2.0 or higher

### 1. checkout and build the code
```
cd $GOPATH/src/github.com/contiv/
git clone https://github.com/contiv/cluster.git
```

### 2. launch three vagrant nodes.

**Note:** If you look at the project's `Vagrantfile`, you will notice that all the vagrant nodes (except for the first node) boot up with stock centos7.2 OS and a `serf` agent running. `serf` is used as the node discovery service. This is intentional to meet the goal of limiting the amount of services that user needs to setup to start bringing up a cluster and hence making management easier.
```
cd cluster/
CONTIV_NODES=3 make demo-cluster
```

### 3. login to the first node to manage the cluster

**Note:** The first node is slightly special in a way that it is booted up with two additional services viz. `collins` and `clusterm`. `collins` is used as the node lifecycle management and event logging service. `clusterm` is the cluster manager daemon. `clusterctl` utility is provided to exercise cluster manager provided REST endpoint.

```
CONTIV_NODES=3 vagrant ssh cluster-node1
```

#### Provision additional nodes

Please see [Cluster](/documents/cluster/node-lifecycle.html) section for more details
