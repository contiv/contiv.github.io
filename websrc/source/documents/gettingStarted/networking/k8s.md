---
layout: "documents"
page_title: "Kubernetes cluster"
sidebar_current: "getting-started-networking-vagrant-k8s"
description: |-
  Setting up Kubernetes cluster
---

## Getting Started with Kubernetes Cluster

This page describes how to set up a Contiv cluster using Kubernetes.

## Prerequisites
* Install CentOS 7.2 on each of your servers used for the Contiv cluster.
* Ensure that each server has at least two, and preferably three, interfaces.
* Choose a server that is on the management network and has Ansible installed. Run the install procedure below on this node.
* If required by your network, set HTTP and HTTPS proxies. Direct the HTTPS proxy to an **http://** URL (not **https://**); this is an Ansible requirement.

### Step 1: Clone the repository

Clone the **git** repository containing the Contiv files.  

```
git clone https://github.com/contiv/demo
```

### Step 2: Clone the contrib repository

Clone the **git** repository containing the Kubernetes contributed code.

```
cd demo/k8s;
git clone https://github.com/jojimt/contrib -b contiv
```

### Step 3: Configure the cluster information
Edit **cluster_defs.json** to reflect your cluster information. See **cluster_defs.json.README** for instructions.

### Step 4 Prepare the nodes
Create an RSA key and save it in the working directory as **id_rsa.pub**.

```
ssh-keygen -t rsa
./prepare.sh
```

### Step 5 Create the cluster
Run the setup script:

```
./setup_k8s_cluster.sh
```

### Step 6 Verify cluster
Run the verification script:

```
./verify_cluster.sh
```
