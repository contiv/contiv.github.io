---
layout: "documents"
page_title: "Installing Mesos"
sidebar_current: "getting-started-networking-vagrant-mesos"
description: |-
  Installing Mesos
---

# Contiv Network with Mesos and Marathon

Contiv Network supports Docker containerizer with Mesos and Marathon. 
This page explains how to get started using Contiv Network with Mesos and Marathon. 

## Prerequisites
Download and install the following packages onto your Linux or OS X machine:

- Virtualbox 5.0.2 or later
- Vagrant 1.7.4 or later
- Ansible 1.9.4 or later

## Step 1: Start the Virtual Environment

The following three commands are all you need to clone the repository and start the VMs:

```
$ git clone https://github.com/contiv/netplugin
$ cd netplugin
$ make mesos-docker-demo
```

These commands start a two-node Vagrant setup with Mesos, Marathon and Docker.

Because the script needs to download the VM images and the Mesos and Marathon binaries,
starting the Vagrant VMs and provisioning them can take few minutes to complete.

The script also builds Contiv Network binaries and starts them on both VMs.

## Step 2: Log Into a VM and Create a Network

The following command creates a network called `contiv` on one of the Vagrant nodes:

```
$ cd demo/mesos-docker; vagrant ssh node1
<Inside vagrant VM>
$ netctl net create contiv -subnet 10.1.1.0/24
```

You can launch in the `contiv` network.

## Step 3: Launch Containers

The `docker.json` file in the `mgmtfn/mesos-docker` directory has an example 
Marathon app definition like the following:

```
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "libmesos/ubuntu",
      "parameters": [ { "key": "net", "value": "contiv" } ]
    }
  },
  "id": "ubuntu",
  "instances": 2,
  "constraints": [ ["hostname", "UNIQUE", ""] ],
  "cpus": 1,
  "mem": 128,
  "uris": [],
  "cmd": "while sleep 10; do date -u +%T; done"
}
```

This example application definition launches two Ubuntu containers with a 
constraint that the containers be deployed on different hosts.
Note that there is a special `net` parameter used in the specification's `"parameters"`: 

```[ { "key": "net", "value": "contiv" } ]```. 

This parameter instructs Docker to launch the application in the Contiv network that you created in Step 3.

You can launch the application using the following command:

```
$ ./launch.sh docker.json
```

Downloading the container image can take few minutes.

Once the application is launched, examine the containers as follows:

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
2a68fed77d5a        libmesos/ubuntu     "/bin/sh -c 'while sl"   About an hour ago   Up About an hour                       mesos-cce1c91f-65fb-457d-99af-5fdd4af14f16-S1.da634e3c-1fde-479a-b100-c61a498bcbe7
 ```

## Notes

 1. Mesos and Marathon ports are port-mapped from the Vagrant VMs to your host machine. 
You can access them by logging into localhost:5050 and localhost:8080 respectively.
 2. The `netmaster` REST API is port-mapped to port 9090 on the host machine.
