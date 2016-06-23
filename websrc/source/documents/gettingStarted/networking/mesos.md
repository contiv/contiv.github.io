---
layout: "documents"
page_title: "Installing Mesos"
sidebar_current: "getting-started-networking-vagrant-mesos"
description: |-
  Installing Mesos
---

## Getting Started with Mesos

These instructions describe how to connect two containers
over a network you create. The network has
its own unique interfaces and lies behind an OVS bridge.

### Prerequisites
- Mesos version 3.0 or higher


### Step 1: Download Mesos.

```
$ git clone https://github.com/contiv/netplugin
$ cd netplugin; make demo
$ Mesos ssh netplugin-node1
```

### Step 2: Install Mesos.

```
$ netctl net create contiv-net --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1001
$ docker run -itd --name=web --net=contiv-net ubuntu /bin/bash
$ docker run -itd --name=db --net=contiv-net ubuntu /bin/bash
```

### Step 3: Log into a container and test the network.

```
$ docker exec -it web /bin/bash
< inside the container >
root@f90e7fd409c4:/# ping db
PING db (20.1.1.3) 56(84) bytes of data.
64 bytes from db (20.1.1.3): icmp_seq=1 ttl=64 time=0.658 ms
64 bytes from db (20.1.1.3): icmp_seq=2 ttl=64 time=0.103 ms
```
