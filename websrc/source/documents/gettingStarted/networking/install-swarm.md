---
layout: "documents"
page_title: "Swarm Cluster"
sidebar_current: "getting-started-networking-installation-swarm"
description: |-
  Setting up a Swarm Cluster.
---

# Using Contiv Network with Docker Swarm

Docker Swarm is a scheduler that schedules containers to multiple hosts.
This page demonstrates how to user Contiv Network with Docker Swarm.

### Using Swarm
The Contiv Network Vagrant setup comes pre-installed with Docker Swarm.
Set the following environment variable to make the Docker client connect
to Swarm:

```
export DOCKER_HOST=tcp://192.168.2.10:2375
```
Now, you should be able to see the information about the Swarm cluster.

```
$ docker info
Containers: 0
Images: 5
Engine Version:
Role: primary
Strategy: spread
Filters: affinity, health, constraint, port, dependency
Nodes: 2
 netplugin-node1: 192.168.2.10:2385
  └ Containers: 0
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 2.051 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.0.0-040000-generic, operatingsystem=Ubuntu 15.04, storagedriver=devicemapper
 netplugin-node2: 192.168.2.11:2385
  └ Containers: 0
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 2.051 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.0.0-040000-generic, operatingsystem=Ubuntu 15.04, storagedriver=devicemapper
CPUs: 8
Total Memory: 4.103 GiB
Name: netplugin-node1
No Proxy: 192.168.0.0/16,localhost,127.0.0.0/8
```

Next, you can see if there are any containers running in the cluster
```
$ docker ps
CONTAINER ID        IMAGE                          COMMAND             CREATED             STATUS              PORTS               NAMES
4dd09bc36875        ubuntu                         "bash"              52 minutes ago      Up 52 minutes                           netplugin-node1/reverent_allen
18bdc2cde778        skynetservices/skydns:latest   "/skydns"           3 hours ago         Up 3 hours          53/udp, 53/tcp      netplugin-node1/defaultdns

```

You can run containers and attach them to contiv networks or endpoint groups just like before.
```
$ docker run -itd --net web.contiv-net ubuntu bash
f291e269b45a5877f6fc952317feb329e12a99bda3a44a740b4c3307ef87954c
```
Here, `docker run` happens against the swarm cluster. Swarm schedules the container to one of the nodes and netplugin on that node sets up the networking and policies just like before.
