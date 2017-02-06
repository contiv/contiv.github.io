---
layout: "documents"
page_title: "Kubernetes cluster"
sidebar_current: "getting-started-networking-installation-k8s"
description: |-
  Setting up Kubernetes cluster
---

# Installing Contiv Network with Kubernetes

This page describes how to set up a Contiv cluster using Kubernetes.

## Prerequisites

1. Install Centos 7.2 on all servers used for the Contiv cluster.
2. Ensure that each server has at least two, and preferably three, interfaces.
3. If required by your network, set HTTP and HTTPS proxies. Direct the HTTPS proxy to an *http://* URL (not *https://*). This is an Ansible requirement.
4. Choose a server that is on the management network and has Ansible installed. Run the install procedure below on this node. This *install node* manages the installation in addition to being part of your cluster.
5. The setup scripts use the Python module *netaddr* and the Linux utility *bzip2*. If these are not installed on the machine where you are executing these steps, you must install them before proceeding. (You can use the following commands: `yum install bzip2; pip install netaddr`.)
5. Enable passwordless SSH access from the installation server to all the other servers in the cluster. 
An example is [here](http://www.linuxproblem.org/art_9.html).
6. Enable passwordless sudo on all servers.  For example:
[here](http://askubuntu.com/questions/192050/how-to-run-sudo-command-with-no-password).
7. Make a note of the IP addresses (or DNS names) of all the servers, and of the network
interfaces on which these IP addresses are configured.

## Step 1: Clone the Repository

Clone the GitHub repository containing the Contiv files:  

```
git clone https://github.com/contiv/demo
```

## Step 2: Clone the Contrib Repository

Clone the GitHub repository containing the Kubernetes contributed code:

```
cd demo/k8s;
git clone https://github.com/jojimt/contrib -b contiv
```

## Step 3: Configure the Cluster Information
Edit the `cluster_defs.json` file to reflect your cluster information. 
See the `cluster_defs.json.README` file for instructions.

*Note*: For ACI integration, edit `aci.yaml`. See [here](aci.html) for more information.

## Step 4 Prepare the Nodes
Run the prepare script. Supply the login and *sudo* passwords when prompted.

```
./prepare.sh <login_userid>
```

## Step 5: Create the Cluster
Run the setup script. Supply the login and *sudo* passwords when prompted.
This script can take several minutes to complete.

```
./setup_k8s_cluster.sh <login_userid>
```

## Step 6 Verify the Cluster
Run the verification script. Supply the login and *sudo* passwords when prompted.

```
./verify_cluster.sh <login_userid>
```
