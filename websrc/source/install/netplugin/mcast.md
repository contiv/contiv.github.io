---
layout: "install"
page_title: "Demonstrating Multicast"
sidebar_current: "getting-started-mcast"
description: |-
  Demonstrating Multicast
---

## Demonstrating Multicast in Contiv
This document illustrates how to demonstrate multicast in a Contiv network.

For the demonstration you run two containers, one on each VM. You create a VLAN network
and run a sender and a receiver multicast application. 

#### Step 1: Clone the Contiv Network repository.
Clone the Contiv Network repository from GitHub as follows.

```
$ git clone https://github.com/contiv/netplugin
$ cd netplugin
```

#### Step 2: Create the VMs.
Create the VMs, then log into the first VM (Node 1) and create a multicast-enabled network as shown below.


```
$ make demo
$ vagrant ssh netplugin-node1
netplugin-node1~$ netctl net create contiv-net --encap=vlan --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1010
```

#### Step 3: Run a Docker container and start the multicast sender application.
Use the commands below to start a new CentOS Docker container, log into the container, and start the **mcast** application.
 (The **mcast.py** command does not return to a prompt.)

```
netplugin-node1~$ docker pull qiwang/centos7-mcast
netplugin-node1~$ docker run -it --name=msender --net=contiv-net qiwang/centos7-mcast /bin/bash
root@9f4e7fd418c5:/# cd /root
root@9f4e7fd418c5:/# ./mcast.py -s -i eth0
```

#### Step 4: Log in to Node 2
Log in to the second VM (Node 2):

`vagrant ssh netplugin-node2`

#### Step 5: Run a Docker container in the network and start the multicast receiver.
Use the Docker commands below to start a new Docker container, then log into the container. 

```
netplugin-node2~$ docker pull qiwang/centos7-mcast
netplugin-node2~$ docker run -it --name=mreceiver --net=contiv-net qiwang/centos7-mcast /bin/bash
root@564f7f4424c1:/# cd /root
root@564f7f4424c1:/# ./mcast.py -i eth0

('20.1.1.3', 35624)  '1453881422.973572'
('20.1.1.3', 35624)  '1453881423.977554'
('20.1.1.3', 35624)  '1453881424.978941'
```

where 20.1.1.3 is the IP that was assigned in this case to container msender.


### Steps to run sender and receiver multicasts between a container and a host VM

#### Step 1: Create demo VMs
Use the commands  below to start the VMs and create a multicast-enabled network.

```
$ make demo
$ vagrant ssh netplugin-node1
netplugin-node1~$ netctl net create contiv-net --encap=vlan --subnet=20.1.1.0/24 --gateway=20.1.1.254 --pkt-tag=1010
```

#### Step 2: Create a port on the OVS with the network tag used for contiv-net
```
netplugin-node1~$ sudo ovs-vsctl add-port contivVlanBridge inb01 -- set interface inb01 type=internal
netplugin-node1~$ sudo ovs-vsctl set port inb01 tag=1010
netplugin-node1~$ sudo ifconfig inb01 30.1.1.8/24
```

#### Step 3: Launch a multicast sender application
Download and launch the **mcast.py** sender application.

```
netplugin-node1~$ git clone https://github.com/leslie-wang/py-multicast-example.git
netplugin-node1~$ cd py-multicast-example
netplugin-node1~$ sudo ./mcast.py -s -i inb01
```

#### Step 4: Login to netplugin-node2
`$ vagrant ssh netplugin-node2`

#### Step 5: Run a Docker container in the network created and launch multicast receiver.
```
netplugin-node2~$ docker pull qiwang/centos7-mcast
netplugin-node2~$ docker run -it --name=mreceiver --net=contiv-net qiwang/centos7-mcast /bin/bash
root@426b8cdbf5f8:/# cd /root
root@426b8cdbf5f8:/# ./mcast.py -i eth0

('30.1.1.8', 35678)  '1453882966.102203'
('30.1.1.8', 35678)  '1453882967.120764'
('30.1.1.8', 35678)  '1453882968.12215'
```
