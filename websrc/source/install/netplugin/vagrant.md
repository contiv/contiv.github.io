---
layout: "install"
page_title: "Install Netplugin"
sidebar_current: "getting-started"
description: |-
  Installing netplugin.
---

### Getting Started with vagrant

This will provide you with a minimal experience of uploading the intent and
seeing the netplugin system act on it. It will create a network on your host
that lives behind an OVS bridge and has its own unique interfaces.

#### Step 1: Clone the project and bringup the VMs

```
$ git clone https://github.com/contiv/netplugin
$ cd netplugin; make demo
$ vagrant ssh netplugin-node1
```

#### Step 2: Create a network

```
$ netctl net create contiv-net --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1001
```

#### Step 3: Run your containers and enjoy the networking!

```
$ docker run -itd --name=web --net=contiv-net ubuntu /bin/bash
$ docker run -itd --name=db --net=contiv-net ubuntu /bin/bash
$ docker exec -it web /bin/bash
< inside the container >
root@f90e7fd409c4:/# ping db
PING db (20.1.1.3) 56(84) bytes of data.
64 bytes from db (20.1.1.3): icmp_seq=1 ttl=64 time=0.658 ms
64 bytes from db (20.1.1.3): icmp_seq=2 ttl=64 time=0.103 ms
```
