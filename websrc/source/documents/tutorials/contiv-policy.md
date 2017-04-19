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
See prerequisites section for [Container Networking Tutorial](/documents/tutorials/container-101.html).

### Setup
Follow all steps for Setup section for [Container Networking Tutorial](/documents/tutorials/container-101.html).

### Chapter 1 - ICMP Policy

In this section, we will create two groups epgA and epgB, and we will create containers belonging to these groups.
By default, communication between groups belonging to same network is allowed. 
So we will add ICMP deny policy and verify that we are not able to ping among those containers.

Let us create Tenant and Network first.

```
[vagrant@contiv-node3 ~]$ export DOCKER_HOST=tcp://192.168.2.52:2375
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

Let us create two containers on each group network and check whether they are able to ping each other or not.
By default, Contiv allows connectivity between groups under same network.

```
[vagrant@contiv-node3 ~]$ docker run -itd --net="epgA/TestTenant" --name=AContainer contiv/alpine sh
d1c6376bebdbd93392131dce08887117460c801be1f1540e0f25ee990aa9003b

[vagrant@contiv-node3 ~]$ docker run -itd --net="epgB/TestTenant" --name=BContainer contiv/alpine sh
4a4ce395f99b6f0e4f8963724a2dd04c46c2d88375f7ac3870435f46bdc4aa30

[vagrant@contiv-node3 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS               NAMES
4a4ce395f99b        contiv/alpine                    "sh"                     51 seconds ago       Up 50 seconds                           contiv-node4/BContainer
d1c6376bebdb        contiv/alpine                    "sh"                     About a minute ago   Up 59 seconds                           contiv-node3/AContainer
8874e51e9f3b        contiv/auth_proxy:1.0.0   "./auth_proxy --tls-k"   10 minutes ago       Up 10 minutes                           contiv-node3/auth-proxy
767c6a3fd784        quay.io/coreos/etcd:v2.3.8       "/etcd"                  13 minutes ago       Up 13 minutes                           contiv-node4/etcd
a56c3ab35cbf        quay.io/coreos/etcd:v2.3.8       "/etcd"                  13 minutes ago       Up 13 minutes                           contiv-node3/etcd


```

Try to ping from AContainer to BContainer. They should be able to ping each other.

```
[vagrant@contiv-node3 ~]$ docker exec -it BContainer sh
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

Add ICMP Deny policy from epgA and modify group epgB to associate this policy.

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

Now ping between containers should not work.


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

In this section, we will create TCP deny policy as well as selective TCP port allow policy.

```

[vagrant@contiv-node3 ~]$ netctl policy rule-add -t TestTenant -d in --protocol tcp --port 0  --from-group epgA  --action deny policyAB 2
[vagrant@contiv-node3 ~]$ netctl policy rule-add -t TestTenant -d in --protocol tcp --port 8001  --from-group epgA  --action allow --priority 10 policyAB 3
[vagrant@contiv-node3 ~]$ netctl policy rule-ls -t TestTenant policyAB
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1         epgA                                              icmp      0     deny
2     1         epgA                                              tcp       0     deny
3     10        epgA                                              tcp       8001  allow
Outgoing Rules:
Rule  Priority  To EndpointGroup  To Network  To IpAddress  Protocol  Port  Action
----  --------  ----------------  ----------  ---------     --------  ----  ------

```

Now check that from epgB, only TCP 8001 port is open. To test this, Let us run iperf on BContainer and
verify using nc utility on AContainer.


```
On BContainer:

[vagrant@contiv-node3 ~]$ docker exec -it BContainer sh
/ # iperf -s -p 8001
------------------------------------------------------------
Server listening on TCP port 8001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
```

On AContainer:

```
[vagrant@contiv-node3 ~]$ docker exec -it AContainer sh
/ # nc -zvw 1 10.1.1.2 8001 -------> here 10.1.1.2 is IP address of BContainer.
10.1.1.2 (10.1.1.2:8001) open
/ # nc -zvw 1 10.1.1.2 8000
10.1.1.2 (10.1.1.2:8000): Operation timed out
/ #
```

You see that port 8001 is open and port 8000 is not open.

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
[vagrant@contiv-node3 ~]$ docker run -itd --net="epgA/BandwidthTenant" --name=serverA contiv/alpine sh
6112c6697df2c43491a23e02d3d8bc3f621b91d59c64226382789ba15082c71b
[vagrant@contiv-node3 ~]$ docker run -itd --net="epgA/BandwidthTenant" --name=clientA contiv/alpine sh
c783d6c3f546d6053953bd664045aa35397756656247255a7e0cbb4201b5514c
[vagrant@contiv-node3 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
c783d6c3f546        contiv/alpine                    "sh"                     5 seconds ago       Up 3 seconds                            contiv-node4/clientA
6112c6697df2        contiv/alpine                    "sh"                     7 seconds ago       Up 5 seconds                            contiv-node4/serverA
b6e0601d8c13        contiv/auth_proxy:1.0.0   "./auth_proxy --tls-k"   4 minutes ago       Up 4 minutes                            contiv-node3/auth-proxy
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

[vagrant@contiv-node4 ~]$ export DOCKER_HOST=tcp://192.168.2.52:2375
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
b6e0601d8c13        contiv/auth_proxy:1.0.0   "./auth_proxy --tls-k"   17 minutes ago      Up 17 minutes                           contiv-node3/auth-proxy
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

[vagrant@contiv-node4 ~]$ docker exec -it clientB sh
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
