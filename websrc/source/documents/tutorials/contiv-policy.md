---
layout: "documents"
page_title: "Contiv Policy Networking Tutorial"
sidebar_current: "contiv-policy"
description: |-
  Contiv Policy Networking Tutorial
---


## Contiv Policy Tutorial
**Note**:
- Please make sure you have you have taken this tutorial before starting this one [Container Networking Tutorial](/documents/tutorials/container-101.html)

This tutorial walks through advanced features of contiv container networking.

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
$ git clone https://github.com/contiv/install.git
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

-- or --

#### Step 2a: Create a vagrant VM cluster

```
make cluster
```

This will create two VMs on VirtualBox. It will also create a .cfg.yml config file that will be used in later steps. Also setup the following two config vars

```
cd cluster
export SSH_KEY=$(vagrant ssh-config contiv-node3 | grep IdentityFile | awk '{print $2}' | xargs)
export USER="vagrant"
```

#### Step 2b: Download contiv release bundle

```
wget https://github.com/contiv/install/releases/download/1.0.0/contiv-1.0.0.tgz
tar -zxvf contiv-1.0.0.tgz
```

#### Step 2c: Use config file to install contiv
```
cd contiv-1.0.0
./install/ansible/install_swarm.sh -f ../.cfg.yml -e ${SSH_KEY} -u ${USER} -i
cd ..
```

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

```

To run docker without sudo, add user to docker group, quit and ssh again.
```
[vagrant@contiv-node3 ~]$ sudo usermod -aG docker $USER
```


```
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
```

`netctl` is a utility to create, update, read and modify contiv objects. It is a CLI wrapper
on top of REST interface.

```
[vagrant@contiv-node3 ~]$ netctl version
Client Version:
Version: 1.0.0
GitCommit: 7290b65
BuildTime: 04-15-2017.18-50-53.UTC

Server Version:
Version: 1.0.0
GitCommit: 7290b65
BuildTime: 04-15-2017.18-50-53.UTC

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


### Chapter 3 - Bandwidth Policy

In this chapter, we will explore bandwidth policy feature of contiv. 
We will create tenant, network and groups. Then we will attach netprofile to one group
and verify that applied bandwidth is working or not as expected in data path.


So, let us create tenant, a network and group "A" under network.


```
[vagrant@contiv-node3 ~]$ netctl tenant create BandwidthTenant
Creating tenant: BandwidthTenant
[vagrant@contiv-node3 ~]$ netctl network create --tenant BandwidthTenant --subnet=50.1.1.0/24 --gateway=50.1.1.254 -p 1001 -e "vlan" BandwidthTestNet
Creating network BandwidthTenant:BandwidthTestNet
[vagrant@contiv-node3 ~]$ netctl group create -t BandwidthTenant BandwidthTestNet epgA
Creating EndpointGroup BandwidthTenant:epgA
[vagrant@contiv-node3 ~]$ netctl net ls -a
Tenant           Network           Nw Type  Encap type  Packet tag  Subnet       Gateway     IPv6Subnet  IPv6Gateway
------           -------           -------  ----------  ----------  -------      ------      ----------  -----------
BandwidthTenant  BandwidthTestNet  data     vlan        1001        50.1.1.0/24  50.1.1.254
[vagrant@contiv-node3 ~]$ netctl group ls -a
Tenant           Group  Network           IP Pool   Policies  Network profile
------           -----  -------           --------  ---------------
BandwidthTenant  epgA   BandwidthTestNet

```

Now, We are going to run serverA and clientA containers using group epgA as a network.


```
[vagrant@contiv-node4 ~]$ export DOCKER_HOST=tcp://192.168.2.52:2375
[vagrant@contiv-node4 ~]$ docker run -itd --net="epgA/BandwidthTenant" --name=serverA contiv/alpine sh
6112c6697df2c43491a23e02d3d8bc3f621b91d59c64226382789ba15082c71b
[vagrant@contiv-node4 ~]$ docker run -itd --net="epgA/BandwidthTenant" --name=clientA contiv/alpine sh
c783d6c3f546d6053953bd664045aa35397756656247255a7e0cbb4201b5514c
[vagrant@contiv-node4 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
c783d6c3f546        contiv/alpine                    "sh"                     5 seconds ago       Up 3 seconds                            contiv-node4/clientA
6112c6697df2        contiv/alpine                    "sh"                     7 seconds ago       Up 5 seconds                            contiv-node4/serverA
b6e0601d8c13        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   4 minutes ago       Up 4 minutes                            contiv-node3/auth-proxy
0c3cb365e573        quay.io/coreos/etcd:v2.3.8       "/etcd"                  7 minutes ago       Up 7 minutes                            contiv-node4/etcd
a9536ad281be        quay.io/coreos/etcd:v2.3.8       "/etcd"                  8 minutes ago       Up 8 minutes                            contiv-node3/etcd

```

Now run iperf server and client to find out current bandwidth which we are getting on the network
where you are running this tutorial. It may vary depending upon base OS , network speed etc.


```
On serverA:

[vagrant@contiv-node3 ~]$ docker exec -it serverA sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:32:01:01:01
          inet addr:50.1.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:32ff:fe01:101%32741/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32741/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # iperf -s -u
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.1 port 5001 connected with 50.1.1.2 port 34700
[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec   0.028 ms    0/  893 (0%)


On clientA:

[vagrant@contiv-node4 ~]$ docker exec -it clientA sh
/ # iperf -c 50.1.1.1 -u
------------------------------------------------------------
Client connecting to 50.1.1.1, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.2 port 34700 connected with 50.1.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec
[  3] Sent 893 datagrams
[  3] Server Report:
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec   0.027 ms    0/  893 (0%)
/ #

```

Now we see that, current bandwidth we are getting is 1.05 Mbits/sec.
So let us create new group B and create netprofile with bandwidth less than the one 
we got above. So let us create netprofile with bandwidth of 500Kbits/sec.

```

[vagrant@contiv-node3 ~]$ netctl netprofile create -t BandwidthTenant -b 500Kbps -d 6 -s 80 testProfile
Creating netprofile BandwidthTenant:testProfile
[vagrant@contiv-node3 ~]$ netctl group create -t BandwidthTenant -n testProfile BandwidthTestNet epgB
Creating EndpointGroup BandwidthTenant:epgB
[vagrant@contiv-node3 ~]$ netctl netprofile ls -a
Name         Tenant           Bandwidth  DSCP      burst size
------       ------           ---------  --------  ----------
testProfile  BandwidthTenant  500Kbps    6         80
[vagrant@contiv-node3 ~]$ netctl group ls -a
Tenant           Group  Network           IP Pool   Policies  Network profile
------           -----  -------           --------  ---------------
BandwidthTenant  epgA   BandwidthTestNet
BandwidthTenant  epgB   BandwidthTestNet              testProfile
[vagrant@contiv-node3 ~]$


```

Running clientB and serverB containers:

```

[vagrant@contiv-node3 ~]$ docker run -itd --net="epgB/BandwidthTenant" --name=serverB contiv/alpine sh
2f4845ed86c5496537ccece77683354e447c28df8f00c10a1a175eb5f44aee76
[vagrant@contiv-node3 ~]$ docker run -itd --net="epgB/BandwidthTenant" --name=clientB contiv/alpine sh
00dde4f46c360e517695e44f2690590ec0af26e125254102147fe79b76331339
[vagrant@contiv-node3 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
00dde4f46c36        contiv/alpine                    "sh"                     2 seconds ago       Up 1 seconds                            contiv-node4/clientB
2f4845ed86c5        contiv/alpine                    "sh"                     4 seconds ago       Up 3 seconds                            contiv-node3/serverB
c783d6c3f546        contiv/alpine                    "sh"                     12 minutes ago      Up 12 minutes                           contiv-node4/clientA
6112c6697df2        contiv/alpine                    "sh"                     12 minutes ago      Up 12 minutes                           contiv-node4/serverA
b6e0601d8c13        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   17 minutes ago      Up 17 minutes                           contiv-node3/auth-proxy
0c3cb365e573        quay.io/coreos/etcd:v2.3.8       "/etcd"                  20 minutes ago      Up 20 minutes                           contiv-node4/etcd
a9536ad281be        quay.io/coreos/etcd:v2.3.8       "/etcd"                  20 minutes ago      Up 20 minutes                           contiv-node3/etcd
[vagrant@contiv-node3 ~]$


```

Now as we are running clientB and serverB containers on group B network. we should see bandwidth around
500Kbps. Thats the verification that our bandwidth netprofile is working as per expectation.

```

On serverB:

[vagrant@contiv-node3 ~]$ docker exec -it serverB sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:32:01:01:03
          inet addr:50.1.1.3  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:32ff:fe01:103%32525/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32525/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # iperf -s -u
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.3 port 5001 connected with 50.1.1.4 port 57180
[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-10.3 sec   692 KBytes   552 Kbits/sec  15.720 ms  411/  893 (46%)


On clientB:

[vagrant@contiv-node3 ~]$ docker exec -it clientB sh
/ # iperf -c 50.1.1.3 -u
------------------------------------------------------------
Client connecting to 50.1.1.3, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.4 port 57180 connected with 50.1.1.3 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec
[  3] Sent 893 datagrams
[  3] Server Report:
[  3]  0.0-10.3 sec   692 KBytes   552 Kbits/sec  15.720 ms  411/  893 (46%)


As we see, clientB is getting roughly around 500Kbps bandwidth.

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
