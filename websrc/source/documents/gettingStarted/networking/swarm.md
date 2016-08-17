---
layout: "documents"
page_title: "Swarm Cluster"
sidebar_current: "getting-started-networking-vagrant-swarm"
description: |-
  Setting up a Swarm Cluster.
---

# Contiv Network with Docker Swarm

This page describes how to quickly create a virtual environment
using the Vagrant environment setup tool. You can then demonstrate
features of Docker and Contiv such as creating containers,
networks, and policies.

## Prerequisites
Before you can install the virtual environment, you must have the following
software packages on your machine:

- VirtualBox 5.0.2 or later
- Vagrant 1.7.4
- Make

## Step 1: Start the Virtual Environment
The following three commands are all you need to clone the repository and start the VMs:

```
$ git clone https://github.com/contiv/netplugin
$ cd netplugin; make demo
$ vagrant ssh netplugin-node1
```
You need to set this exact DOCKER_HOST variable on all 3 nodes before you proceed to next steps.

```
export DOCKER_HOST=192.168.2.10:2375
```
This will make sure that everytime when someone is executing docker / netctl commands,
It will contact docker demon running on 192.168.2.10 node and will not contact local
docker deamon.

These commands start a cluster of three VMs running Docker and Contiv Network, and log
you into one of the VMs.

## Step 2: Create a Network
Use the following command to create a network:

```
netplugin-node1$ netctl net create contiv-net --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1001
```

## Step 3: Run Containers on Two Hosts
Start a Docker container on the node you just logged into:

```
netplugin-node1$ docker run -itd --name=web --net=contiv-net alpine /bin/sh
Note: "alpine" docker image has all network debugging utilities
      such as ping, ip, ifconfig etc...
      Its possible to use any custom image as well.
      The standard "ubuntu" image does not come with debug utilities.
```

In another shell window, log into the second VM and start another Docker container:

```
$ vagrant ssh netplugin-node2
netplugin-node2$ docker run -itd --name=db --net=contiv-net alpine /bin/sh
```

On node 1, log into the container and ping the container on node 2:

```
netplugin-node1$ docker exec -it web /bin/sh
< inside the container >
root@f90e7fd409c4:/# ping db
PING db (20.1.1.3) 56(84) bytes of data.
64 bytes from db (20.1.1.3): icmp_seq=1 ttl=64 time=0.658 ms
64 bytes from db (20.1.1.3): icmp_seq=2 ttl=64 time=0.103 ms
```

## Step 4: Create a Policy
Type the following to create a policy named `prod_web`:

```
$ netctl policy create prod_web
```
## Step 5: Add Rules to the Policy
The following three commands add a default-deny rule to drop all incoming TCP
connections and two rules to explicitly allow traffic on ports 80 and 443.

```
$ netctl policy rule-add prod_web 1 -direction=in -protocol=tcp -action=deny
$ netctl policy rule-add prod_web 2 -direction=in -protocol=tcp -port=80 -action=allow -priority=10
$ netctl policy rule-add prod_web 3 -direction=in -protocol=tcp -port=443 -action=allow -priority=10
```
## Step 6: Create an Endpoint Group
An endpoint group (EPG) is a collection of containers' interfaces on a network. You create an endpoint
group, then assign nodes to it.

Use the following command to create an endpoint group named `web` in network `contiv-net` and attach the
`prod_web` policy to it.

```
$ netctl group create contiv-net web -policy=prod_web
```

*Note*: Every endpoint group creates a seperate Docker network of the form `<endpoint-group-name>.<network-name>`.
You can attach containers to these endpoint groups using the `--net` option in the `docker run` command.

## Step 7: Attach a Container
Next, run a container and attach it to the endpoint group.
The following command runs a Docker container and attaches it to the `web` EPG
in the `contiv-net` network.

```
$ docker run -itd --net web.contiv-net alpine sh
```

## Using Netplugin with Docker Swarm

Docker Swarm is a scheduler that schedules containers to multiple hosts. The `netplugin` service is Contiv's
Docker network plugin that provides multi-host networking. Together, Docker, Swarm, and Contiv Network are 
a powerful combination.

### Using Swarm
The `netplugin` Vagrant setup comes pre-installed with Docker Swarm.
Set the following environment variable to make the Docker client communicate with Swarm.

```
export DOCKER_HOST=tcp://192.168.2.10:2375
```

The Swarm cluster should now be visible.
Type the following to see information about the Swarm cluster:

```
docker info
Containers: 3
Images: 4
Role: primary
Strategy: spread
Filters: health, port, dependency, affinity, constraint
Nodes: 2
 netplugin-node1: 192.168.2.10:2385
  └ Containers: 2
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 2.051 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.3.0-1.el7.elrepo.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
 netplugin-node2: 192.168.2.11:2385
  └ Containers: 1
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 2.051 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.3.0-1.el7.elrepo.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=overlay
CPUs: 8
Total Memory: 4.101 GiB
Name: netplugin-node1
No Proxy: 192.168.2.10,192.168.2.11,127.0.0.1,localhost,netmaster

Note: The above output may vary based on container image used
```

Next, you can see if there are any containers running in the cluster:

```
$ docker ps
CONTAINER ID        IMAGE                          COMMAND             CREATED             STATUS              PORTS               NAMES
4dd09bc36875        alpine                         "/bin/sh"           52 minutes ago      Up 52 minutes                           netplugin-node1/reverent_allen
18bdc2cde778        skynetservices/skydns:latest   "/skydns"           3 hours ago         Up 3 hours          53/udp, 53/tcp      netplugin-node1/defaultdns

```

You can run containers and attach them to Contiv networks or endpoint groups just like before.

```
$ docker run -itd --net web.contiv-net alpine sh
f291e269b45a5877f6fc952317feb329e12a99bda3a44a740b4c3307ef87954c
```
Here, `docker run` executes against the swarm cluster. Swarm schedules the 
container to one of the nodes, then `netplugin` on that node sets up the 
networking and policies just like before.
