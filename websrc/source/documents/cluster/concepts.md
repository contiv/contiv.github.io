---
layout: "documents"
page_title: "Cluster"
sidebar_current: "cluster-concepts"
description: |-
  Cluster
---


# Concepts and Features
This page:

1\. Defines a number of terms important to best understand and use Contiv Cluster.
2\. Describes features that should be present in a clustering product, and describes their implementation in Contiv Cluster.

## Definitions
The following terms are listed in alphabetical order.

### Bootstrap
Bootstraping is provisioning a node or cluster for the first time. Contiv distinguishes two types of bootstrap:

- *Node Bootstrap*: The process of installing the node image and booting the node for the first time.
- *Cluster Bootstrap*: The process of adding one or more bootstrapped nodes to the cluster for the first time.

### Cluster
A collection of one or more nodes running clustering software such as Docker Swarm.
Nodes may or may not all have the same capabilities.

<a name="features"></a>
### Features

Following is a list of features for Contiv Cluster. Not all features are implemented in this early release.

- Node discovery to simplify cluster bootstrapping and expansion
- Cluster management
  - [Inventory](#inventory)
    - Discovery
    - Node state database
  - [Node image management](#node-image-management)
    - Install
    - Upgrade
  - [Node configuration management](#node-configuration-management)
    - Clustering software components (swarm-agent and similar componenets)
    - Infrastructure software components (ovs, serf, consul, etcd, and so on)
    - Contiv infrastructure services (netmaster, netplugin, volplugin, and supporting utilities)
  - [Bootstrap](#bootstrap-1)
    - Node
    - Cluster
  - [Lifecycle](#lifecycle-1)
    - Node
    - Cluster

### Image
An operating system with a *minimal set* of pre-installed packages used by a node. For instance,
node automated discovery requires a cluster membership service like [Serf](https://www.serfdom.io/)
be pre-installed and started on the node during bootstrapping.

### Infra Service
An infrastructure (infra) service is a userspace application or a kernel module on a 
node that provides a support service to the clustering system software. 
Examples include plugins, drivers, components for networking and storage, key-value stores, and so on.

### Lifecycle
A well defined collection of states that a node or cluster transitions through based on system events.

### Node
A physical or virtual server with defined compute, memory, storage and networking capabilities.

## Features
The following sections detail the *cluster management* features listed in the [Features](#features) 
definition. The Contiv Cluster GitHub repository contains a 
[Design Guide](https://github.com/contiv/cluster/management/DESIGN.md) 
that describes technical details of Contiv Cluster features.

<a name="inventory"></a>
### Inventory
Inventory management provides:

- *Cluster Membership Management*: Automatic discovery of nodes and and tracking of discovery status.
- *Node State Database*: Tracking of the current state of the node within the cluster.  Node states consist of the following:
  - *New*: A node that has not completed the bootstrap and discovery process.
  - *Discovered*: A node that has completed bootstrapping, has notified the Cluster Manager, and is waiting to be commissioned.
  - *Commissioned*: A node has been configured to participate in the cluster.
  - *Upgraded*: A node on which one or more node components have been upgraded and is ready to participate in the cluster.
  - *Decommissioned*: A node on which all configuration and software components have been removed. The node no longer participates in the cluster.

<a name="node-configuration-management"></a>
### Node Configuration Management
Node Configuration Management provides:

- *Image Repository*: A central location reachable by nodes where images are hosted. Images are delivered to nodes using mechanisms such as PXE.
- *Image Installation*: Automatic installation of of images on new nodes.
- *Upgrades*: Automatic upgrading of the node image. Upgrades can be automatically triggered and can be performed cluster-wide or rolling.

*Note:* Node Configuration Management features are *not* included in the initial release of Contiv Cluster.
Operators are responsible for node bootstrapping, including image provisioning.

Node Configuration Management provides:

- *Configuration Repository*: A central location for hosting node configuration files.
The configuration is used to automate the deployment of nodes.
- *Configuration Push*: The configuration of nodes is pushed from Cluster Manager to nodes.
- *Configuration Cleanup*: Configuration files, service, packages, etc. are removed from nodes.
- *Configuration Verification*: Checks to ensure that the node configuration is truly functional.
- *Configuration Upgrade*: Automates the process of upgrading node software components.
Upgrades can be automatically triggered and can be performed cluster-wide or rolling.
- *Role/Group-Based Configuration*: Nodes can be assigned a group or role.
Role/Group-Based configuration selectively manages services on nodes statically by the
operator or dynamically based on service availability policy.

*Note:* Dynamic role assignment is *not* supported in initial release of Contiv Cluster.

<a name="bootstrap-1"></a>
### Bootstrap
Contiv provides node and cluster boostrapping.

#### Node
Contiv Cluster provides the following node bootstrapping capabilities:

- Installing the base image.
- Performing initial configurations such as disk partitioning.
- Assigning an IP address.
- Configuring user credentials and permissions to perform configuration management tasks.
- Starting infrastructure services such as Serf.

*Note:* Node bootstrap is *not* provided as part of initial release of Contiv Cluster. Operators are responsible for node bootstrapping, including image provisioning.

#### Cluster
Cluster bootstrap installs and configures clustering software components such as swarm-master
(for Docker Swarm) to the first bootstrapped node with parameters such as:

- Configuration management parameters such as user information, configuration repository.
- Inventory management parameters such as database url.

<a name="lifecycle-1></a>
### Lifecycle
Lifecycle management integrates multiple cluster and node management tasks at a
central location to simplify monitoring and administration of the cluster.

#### Node
Node lifecycle management provides:

- *Bootstrap*: Remotely provision a node's image from a central location. *As described
above this feature is not provided in the initial release of Contiv Cluster.*
- *Cluster Membership*: Automatically track a cluster's membership of reachable and unreachable nodes.
- *Commission*: Remotely provision a node's clustering software, configuration, and so on.
Optionally, commission newly discovered nodes automatically.
- *Upgrade*: Remotely upgrade the image or a software component of a commissioned node.
Optionally, upgrade nodes when a configuration repository changes.
- *Decommission*: Automatically remove configuration, software components, and so on from a commissioned node.
- *Batch operation*: Commission, upgrade, or decommission all or a subset of nodes.
- *Reload*: In the event of a node reload or a lost connection, verify the node configuration
and automate corrective actions.

#### Cluster
Cluster lifecycle management provides:

- *Bootstrap*: Remotely bootstrap a cluster.
- *High Availability*: The cluster manager service is available as long as at least one node is running
in the cluster.
