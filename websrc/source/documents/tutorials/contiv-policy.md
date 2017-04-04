---
layout: "documents"
page_title: "Contiv Policy Networking Tutorial"
sidebar_current: "contiv-policy"
description: |-
  Container Networking Tutorial
---


## Contiv Policy Networking Tutorial
**Note**:
- Please make sure you have you have taken this tutorial before starting this one [Container Networking Tutorial](/documents/tutorials/container-101.html)

This tutorial walks through different policy features of contiv container networking.

### Prerequisites 
1. [Download Vagrant](https://www.vagrantup.com/downloads.html)
2. [Download Virtualbox](https://www.virtualbox.org/wiki/Downloads)
3. [Install git client](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
4. [Install docker for mac](https://docs.docker.com/docker-for-mac/install/)

**Note**:
- If you are using platform other than Mac, please install docker-engine, for that platform.


### Setup

#### Step 1: Get contiv installer code from github.
```
$ git clone git@github.com:contiv/install.git
$ cd install
```

#### Step 2: Run installer to install contiv + Docker Swarm using Vagrant on VMs created on VirtualBox

**Note**:
- Please make sure that you are NOT connected to VPN here.

```
make demo-swarm
```
This will create two VMs on VirtualBox. Using ansible, all the required services and software for contiv, will get installed at this step.
This might take some time (usually approx 15-20 mins) depending upon your internet connection.


#### Step 3: Check vagrant VM nodes

**Note**:
- On Windows, you will need a ssh client to be installed like putty, cygwin etc.

```
This command will show you list of VMs which we have created. 
$ cd cluster
$ vagrant status
Current machine states:

contiv-node3              running (virtualbox)
contiv-node4              running (virtualbox)

```
The above command shows the node information, version, etc.

#### Step 4: Hello world Docker swarm.

As a part of this contiv installation, we install docker swarm for you. To verify docker swarm cluster, please execute
following commands on Vagrant VMs.

```
$ cd cluster
$ vagrant ssh contiv-node3
Now you will be logged into one of the Vagrant VM.
[vagrant@contiv-node3 ~]$ export DOCKER_HOST=tcp://192.168.2.52:2375 (IP address might change depending upon your setup. 
You will see this at the end of installation in setp 2 above)

[vagrant@contiv-node3 ~]$ docker info
Containers: 6
 Running: 6
 Paused: 0
 Stopped: 0
Images: 5
Server Version: swarm/1.2.5
Role: primary
Strategy: spread
Filters: health, port, containerslots, dependency, affinity, constraint
Nodes: 2
 contiv-node3: 192.168.2.52:2385
  └ ID: VTEC:DKHT:6JQ3:3VTA:OIVJ:DTWY:USJ4:BWTV:RSDU:7SQS:KZLQ:ERQN
  └ Status: Healthy
  └ Containers: 4 (4 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.018 GiB
  └ Labels: kernelversion=3.10.0-514.6.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-04-05T03:44:23Z
  └ ServerVersion: 1.12.6
 contiv-node4: 192.168.2.53:2385
  └ ID: DFY4:JOVY:RJOM:BEAT:6TW3:6H3V:3QVZ:DMNR:KXJF:LGSM:D67W:ZM2B
  └ Status: Healthy
  └ Containers: 2 (2 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.018 GiB
  └ Labels: kernelversion=3.10.0-514.6.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-04-05T03:44:22Z
  └ ServerVersion: 1.12.6
Plugins:
 Volume:
 Network:
Swarm:
 NodeID:
 Is Manager: false
 Node Address:
Security Options:
Kernel Version: 3.10.0-514.6.2.el7.x86_64
Operating System: linux
Architecture: amd64
CPUs: 2
Total Memory: 2.036 GiB
Name: contiv-node3
Docker Root Dir:
Debug Mode (client): false
Debug Mode (server): false
WARNING: No kernel memory limit support

```

Docker swarm with 2 nodes is running successfully.

Scheduler schedules these containers using the
scheduling algorithm `bin-packing` or `spread`, and if they are not placed on 
different nodes, feel free to start more containers to see the distribution.

#### Step 5: Check contiv and related services.

`etcdctl` is a control utility to manipulate etcd, state store used by kubernetes/docker/contiv

To check etcd cluster health

```
[vagrant@contiv-node3 ~]$ etcdctl cluster-health
member 6fa216d588021d73 is healthy: got healthy result from http://192.168.2.52:2379
cluster is healthy
```

To check netplugin and netmaster is running successfully.

```
[vagrant@contiv-node3 ~]$ sudo service netmaster status
Redirecting to /bin/systemctl status  netmaster.service
● netmaster.service - Netmaster
   Loaded: loaded (/etc/systemd/system/netmaster.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-04-05 03:38:13 UTC; 1h 24min ago
 Main PID: 19303 (netmaster)
   CGroup: /system.slice/netmaster.service
           └─19303 /usr/bin/netmaster --cluster-mode docker -cluster-store etcd://192.168.2.52:2379

Apr 05 03:39:24 contiv-node3 netmaster[19303]: "
Apr 05 03:39:24 contiv-node3 netmaster[19303]: time="Apr  5 03:39:24.553096492" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9003}"
Apr 05 03:39:24 contiv-node3 netmaster[19303]: time="Apr  5 03:39:24.655632431" level=info msg="Connecting to RPC server: 192.168.2.53:9002"
Apr 05 03:39:24 contiv-node3 netmaster[19303]: time="Apr  5 03:39:24.657559108" level=info msg="Connected to RPC server: 192.168.2.53:9002"
Apr 05 03:39:24 contiv-node3 netmaster[19303]: time="Apr  5 03:39:24.686351579" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9002}"
Apr 05 03:39:25 contiv-node3 netmaster[19303]: time="Apr  5 03:39:25.055993278" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9003}"
Apr 05 03:39:25 contiv-node3 netmaster[19303]: time="Apr  5 03:39:25.057403945" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9002}"
Apr 05 03:39:26 contiv-node3 netmaster[19303]: time="Apr  5 03:39:26.982569554" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9003}"
Apr 05 03:39:26 contiv-node3 netmaster[19303]: time="Apr  5 03:39:26.985850619" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9002}"
Apr 05 03:39:47 contiv-node3 netmaster[19303]: time="Apr  5 03:39:47.370439060" level=info msg="Received EndpointUpdateRequest {{IPAddress: ContainerID: Labels:map[] Tenant: ...mmonName:}}"
Hint: Some lines were ellipsized, use -l to show in full.


[vagrant@contiv-node3 ~]$ sudo service netplugin status
Redirecting to /bin/systemctl status  netplugin.service
● netplugin.service - Netplugin
   Loaded: loaded (/etc/systemd/system/netplugin.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-04-05 03:38:06 UTC; 1h 24min ago
 Main PID: 18715 (netplugin)
   CGroup: /system.slice/netplugin.service
           └─18715 /usr/bin/netplugin -plugin-mode docker -vlan-if eth2 -vtep-ip 192.168.2.52 -ctrl-ip 192.168.2.52 -cluster-store etcd://192.168.2.52:2379

Apr 05 04:53:05 contiv-node3 netplugin[18715]: time="Apr  5 04:53:05.147613969" level=info msg="Link up received for eth2"
Apr 05 04:53:50 contiv-node3 netplugin[18715]: time="Apr  5 04:53:50.094566036" level=info msg="Link up received for eth2"
Apr 05 04:58:50 contiv-node3 netplugin[18715]: time="Apr  5 04:58:50.111429722" level=info msg="Link up received for eth2"
Apr 05 04:59:35 contiv-node3 netplugin[18715]: time="Apr  5 04:59:35.097787227" level=info msg="Link up received for eth2"
Apr 05 04:59:35 contiv-node3 netplugin[18715]: time="Apr  5 04:59:35.117917438" level=info msg="Link up received for eth2"
Apr 05 05:00:20 contiv-node3 netplugin[18715]: time="Apr  5 05:00:20.098625381" level=info msg="Link up received for eth2"
Apr 05 05:00:20 contiv-node3 netplugin[18715]: time="Apr  5 05:00:20.115436793" level=info msg="Link up received for eth2"
Apr 05 05:01:05 contiv-node3 netplugin[18715]: time="Apr  5 05:01:05.103688615" level=info msg="Link up received for eth2"
Apr 05 05:01:05 contiv-node3 netplugin[18715]: time="Apr  5 05:01:05.118184283" level=info msg="Link up received for eth2"
Apr 05 05:01:50 contiv-node3 netplugin[18715]: time="Apr  5 05:01:50.111603433" level=info msg="Link up received for eth2"

`netctl` is a utility to create, update, read and modify contiv objects. It is a CLI wrapper
on top of REST interface.

[vagrant@contiv-node3 ~]$ netctl version
Client Version:
Version: 1.0.0-beta.5
GitCommit: 2b9a58f
BuildTime: 03-30-2017.19-09-51.UTC

Server Version:
Version: 1.0.0-beta.5
GitCommit: 2b9a58f
BuildTime: 03-30-2017.19-09-51.UTC

```

### Chapter 1 - ICMP Policy

In this section, we will create two groups epgA and epgB. We will create container with respect to those groups. 
Then by default communication between group is allowed. So we will have ICMP deny policy and very that we are not able to ping among those containers.

Let us create Tenant and Network first.

```
[vagrant@contiv-node3 ~]$ netctl tenant create TestTenant
Creating tenant: TestTenant
[vagrant@contiv-node3 ~]$ netctl network create --tenant TestTenant --subnet=10.1.1.0/24 --gateway=10.1.1.254 -e "vlan" TestNet
Creating network TestTenant:TestNet
[vagrant@contiv-node3 ~]$ netctl net ls -a
Tenant      Network  Nw Type  Encap type  Packet tag  Subnet       Gateway     IPv6Subnet  IPv6Gateway
------      -------  -------  ----------  ----------  -------      ------      ----------  -----------
TestTenant  TestNet  data     vlan        0           10.1.1.0/24  10.1.1.254

```

Now, create two groups epgA and epgB, under network TestNet.


```
vagrant@contiv-node3 ~]$ netctl group create -t TestTenant TestNet epgA
Creating EndpointGroup TestTenant:epgA
[vagrant@contiv-node3 ~]$ netctl group create -t TestTenant TestNet epgB
Creating EndpointGroup TestTenant:epgB
[vagrant@contiv-node3 ~]$ netctl group ls -a
Tenant      Group  Network  IP Pool   Policies  Network profile
------      -----  -------  --------  ---------------
TestTenant  epgA   TestNet
TestTenant  epgB   TestNet

```

Now you will see thse groups and networks are reported as network to docker-engine, with driver listed as netplugin.


```

[vagrant@contiv-node3 ~]$ docker network ls
NETWORK ID          NAME                  DRIVER              SCOPE
85f8144b5793        TestNet/TestTenant    netplugin           global
dc4bf5c0a3f6        contiv-node3/bridge   bridge              local
8ba7d938a5a6        contiv-node3/host     host                local
ce0ed5eeb959        contiv-node3/none     null                local
f582a71ef87c        contiv-node4/bridge   bridge              local
9a79b6aa93d3        contiv-node4/host     host                local
bb41a59343f7        contiv-node4/none     null                local
f265e28064e3        epgA/TestTenant       netplugin           global
5991ae9fafc0        epgB/TestTenant       netplugin           global

```

Now Let us create two containers on each group network and check whether they are abel to ping each other or not.
By default, Contiv allows ping between groups under same network.

```

[vagrant@contiv-node3 ~]$ docker run -itd --net="epgA/TestTenant" --name=AContainer contiv/alpine sh
d1c6376bebdbd93392131dce08887117460c801be1f1540e0f25ee990aa9003b

Log on to contiv-node4 and export DOCKER_HOST.
[vagrant@contiv-node4 ~]$ docker run -itd --net="epgB/TestTenant" --name=BContainer contiv/alpine sh
4a4ce395f99b6f0e4f8963724a2dd04c46c2d88375f7ac3870435f46bdc4aa30

[vagrant@contiv-node3 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS               NAMES
4a4ce395f99b        contiv/alpine                    "sh"                     51 seconds ago       Up 50 seconds                           contiv-node4/BContainer
d1c6376bebdb        contiv/alpine                    "sh"                     About a minute ago   Up 59 seconds                           contiv-node3/AContainer
8874e51e9f3b        contiv/auth_proxy:1.0.0-beta.5   "./auth_proxy --tls-k"   10 minutes ago       Up 10 minutes                           contiv-node3/auth-proxy
767c6a3fd784        quay.io/coreos/etcd:v2.3.8       "/etcd"                  13 minutes ago       Up 13 minutes                           contiv-node4/etcd
a56c3ab35cbf        quay.io/coreos/etcd:v2.3.8       "/etcd"                  13 minutes ago       Up 13 minutes                           contiv-node3/etcd


```

Now try to ping from AContainer to BContainer. They should be able to ping each other.

```

[vagrant@contiv-node4 ~]$ docker exec -it BContainer sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:01:02
          inet addr:10.1.1.2  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:102%32606/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:956 (956.0 B)  TX bytes:886 (886.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32606/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


[vagrant@contiv-node3 ~]$ docker exec -it Acontainer sh
Error response from daemon: No such container Acontainer
[vagrant@contiv-node3 ~]$ docker exec -it AContainer sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:01:01
          inet addr:10.1.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:101%32716/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32716/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # ping 10.1.1.2
PING 10.1.1.2 (10.1.1.2) 56(84) bytes of data.
64 bytes from 10.1.1.2: icmp_seq=1 ttl=64 time=2.43 ms
64 bytes from 10.1.1.2: icmp_seq=2 ttl=64 time=0.836 ms
^C
--- 10.1.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 0.836/1.633/2.430/0.797 ms
/ # exit


```

Now add ICMP Deny policy. Container should not be abel to ping each other now.

Adding policy and modifying group.

```

[vagrant@contiv-node3 ~]$ netctl policy create -t TestTenant policyAB
Creating policy TestTenant:policyAB
[vagrant@contiv-node3 ~]$ netctl policy rule-add -t TestTenant -d in --protocol icmp  --from-group epgA  --action deny policyAB 1
[vagrant@contiv-node3 ~]$ netctl group create -t TestTenant -p policyAB TestNet epgB
Creating EndpointGroup TestTenant:epgB
[vagrant@contiv-node3 ~]$ netctl policy ls -a
Tenant      Policy
------      ------
TestTenant  policyAB

[vagrant@contiv-node3 ~]$ netctl policy rule-ls -t TestTenant policyAB
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1         epgA                                              icmp      0     deny
Outgoing Rules:
Rule  Priority  To EndpointGroup  To Network  To IpAddress  Protocol  Port  Action
----  --------  ----------------  ----------  ---------     --------  ----  ------

```

Now ping between containers.


```

[vagrant@contiv-node3 ~]$ docker exec -it AContainer sh
/ # ping 10.1.1.2
PING 10.1.1.2 (10.1.1.2) 56(84) bytes of data.
^C
--- 10.1.1.2 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3002ms

/ # exit

```

### Chapter 2 - TCP Policy

In this section, We will add TCP 8001 port allow policy and then will verify this policy.

Creating TCP port policy.

```

[vagrant@contiv-node3 ~]$ netctl policy rule-add -t TestTenant -d in --protocol tcp --port 8001  --from-group epgA  --action allow policyAB 3
[vagrant@contiv-node3 ~]$ netctl policy rule-ls -t TestTenant policyAB
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1         epgA                                              icmp      0     deny
3     1         epgA                                              tcp       8001  allow
Outgoing Rules:
Rule  Priority  To EndpointGroup  To Network  To IpAddress  Protocol  Port  Action
----  --------  ----------------  ----------  ---------     --------  ----  ------

```

Now check that from app group, only TCP 8001 port is open. To test this, Let us run iperf on BContainer and
verify using nc utility on BContainer.


```
On AContainer:

[vagrant@contiv-node3 ~]$ docker exec -it AContainer sh
/ # iperf -s -p 8001
------------------------------------------------------------
Server listening on TCP port 8001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------



On BContainer:

[vagrant@contiv-node4 ~]$ docker exec -it BContainer sh
/ # nc -zvw 1 10.1.1.1 8001 -------> here 10.1.1.1 is IP address of AContainer.
10.1.1.1 (10.1.1.1:8001) open
/ # nc -zvw 1 10.1.1.1 8000
/ #

You see that port 8001 is open and port 8000 is not open.

```

### Cleanup: **after all play is done**
To cleanup the setup, after doing all the experiments, exit the VM destroy VMs:

```
[vagrant@contiv-node3 ~]$ exit

$ cd .. (just to come out of cluster dir)
$ make cluster-destroy
cd cluster && vagrant destroy -f
==> contiv-node4: Forcing shutdown of VM...
==> contiv-node4: Destroying VM and associated drives...
==> contiv-node3: Forcing shutdown of VM...
==> contiv-node3: Destroying VM and associated drives...

```


### Improvements or Comments
This tutorial was developed by Contiv engineers. Thank you for trying out this tutorial.
Please file a GitHub issue if you see an issue with the tutorial, or if you prefer
improving some text, feel free to send a pull request.
