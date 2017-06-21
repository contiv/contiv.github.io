---
layout: "documents"
page_title: "Contiv Policy Networking Tutorial (Legacy Swarm)"
sidebar_current: "contiv-policy"
description: |-
  Contiv Policy Networking Tutorial (Legacy Swarm)
---


## Contiv Policy Tutorial with Legacy Swarm

This tutorial walks through advanced features of Contiv container networking.

### Setup
Follow all steps from the [Container Networking Tutorial](/documents/tutorials/container-101.html).

### Chapter 1 - ICMP Policy

In this section, we will create two groups epgA and epgB. We will create containers with respect to those groups. Then, by default, communication between the groups is allowed. So, we will create an ICMP deny policy and verify that we are not able to ping between those containers.

Let's create a Tenant and Network first.

```
[vagrant@legacy-swarm-master ~]$ export DOCKER_HOST=tcp://192.168.2.50:2375
[vagrant@legacy-swarm-master ~]$ netctl tenant create TestTenant
Creating tenant: TestTenant
```
Create a network under this tenant.

```
[vagrant@legacy-swarm-master ~]$ netctl network create --tenant TestTenant --subnet=10.1.1.0/24 --gateway=10.1.1.254 -e "vlan" TestNet
Creating network TestTenant:TestNet
```
We can see the networks that are present within the cluster.

```
[vagrant@legacy-swarm-master ~]$ netctl net ls -a
Tenant      Network  Nw Type  Encap type  Packet tag  Subnet       Gateway     IPv6Subnet  IPv6Gateway
------      -------  -------  ----------  ----------  -------      ------      ----------  -----------
TestTenant  TestNet  data     vlan        0           10.1.1.0/24  10.1.1.254
```

Now create two network groups under network TestNet.

```
vagrant@legacy-swarm-master ~]$ netctl group create -t TestTenant TestNet epgA
Creating EndpointGroup TestTenant:epgA
[vagrant@legacy-swarm-master ~]$ netctl group create -t TestTenant TestNet epgB
Creating EndpointGroup TestTenant:epgB
```
We can list the network groups as well.

```
[vagrant@legacy-swarm-master ~]$ netctl group ls -a
Tenant      Group  Network  IP Pool   Policies  Network profile
------      -----  -------  --------  ---------------
TestTenant  epgA   TestNet
TestTenant  epgB   TestNet

```

Now we will see these groups and networks are reported as networks to docker-engine, with the driver listed as netplugin.

```

[vagrant@legacy-swarm-master ~]$ docker network ls
NETWORK ID          NAME                          DRIVER              SCOPE
f38fe5758042        TestNet/TestTenant            netplugin           global
6b438745a206        epgA/TestTenant               netplugin           global
d595ad64ccaf        epgB/TestTenant               netplugin           global
d27068896366        legacy-swarm-master/bridge    bridge              local
1771861879cf        legacy-swarm-master/host      host                local
f7d7643491f3        legacy-swarm-master/none      null                local
83f0ad7997e2        legacy-swarm-worker0/bridge   bridge              local
7f2342d24e6a        legacy-swarm-worker0/host     host                local
506fc42e2a35        legacy-swarm-worker0/none     null                local

```

Let's create two containers, one on each group network, and check whethere they are able to ping each other or not. By default, Contiv allows connectivity between groups under the same network.

```
[vagrant@legacy-swarm-master ~]$ docker run -itd --net="epgA/TestTenant" --name=AContainer contiv/alpine sh
d1c6376bebdbd93392131dce08887117460c801be1f1540e0f25ee990aa9003b

[vagrant@legacy-swarm-master ~]$ docker run -itd --net="epgB/TestTenant" --name=BContainer contiv/alpine sh
4a4ce395f99b6f0e4f8963724a2dd04c46c2d88375f7ac3870435f46bdc4aa30

[vagrant@legacy-swarm-master ~]$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS               NAMES
d50a96536aeb        contiv/alpine                "sh"                     7 seconds ago       Up 6 seconds                            legacy-swarm-worker0/BContainer
32e87214aedd        contiv/alpine                "sh"                     30 seconds ago      Up 29 seconds                           legacy-swarm-worker0/AContainer
654e678abd24        contiv/auth_proxy:1.0.3      "./auth_proxy --tls-k"   9 hours ago         Up 9 hours                              legacy-swarm-master/auth-proxy
e8f9f40077f1        quay.io/coreos/etcd:v2.3.8   "/etcd"                  9 hours ago         Up 9 hours                              legacy-swarm-worker0/etcd
7810f563e836        quay.io/coreos/etcd:v2.3.8   "/etcd"                  9 hours ago         Up 9 hours                              legacy-swarm-master/etcd
```

Try to ping from AContainer to BContainer. They should be able to ping each other.

```
[vagrant@legacy-swarm-master ~]$ docker exec -it BContainer sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:01:02
          inet addr:10.1.1.2  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:102/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # exit
```
```
[vagrant@legacy-swarm-master ~]$ docker exec -it AContainer sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:01:01
          inet addr:10.1.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:101/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # ping -c 3 10.1.1.2
PING 10.1.1.2 (10.1.1.2): 56 data bytes
64 bytes from 10.1.1.2: seq=0 ttl=64 time=1.188 ms
64 bytes from 10.1.1.2: seq=1 ttl=64 time=0.087 ms
64 bytes from 10.1.1.2: seq=2 ttl=64 time=0.098 ms

--- 10.1.1.2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.087/0.457/1.188 ms
/ # exit
```

Now let’s add an ICMP Deny policy and modify group epgB. The containers should not be able to ping each other now.

Create the policy.

```
[vagrant@legacy-swarm-master ~]$ netctl policy create -t TestTenant policyAB
Creating policy TestTenant:policyAB 
```
Add a rule to the policy.

```
[vagrant@legacy-swarm-master ~]$ netctl policy rule-add -t TestTenant -d in --protocol icmp --from-group epgA --action deny policyAB 1
```
Create a group associated with this policy.

```
[vagrant@legacy-swarm-master ~]$ netctl group create -t TestTenant -p policyAB TestNet epgB
Creating EndpointGroup TestTenant:epgB 
```
```
[vagrant@legacy-swarm-master ~]$ netctl policy ls -a
Tenant      Policy
------      ------
TestTenant  policyAB

[vagrant@legacy-swarm-master ~]$ netctl policy rule-ls -t TestTenant policyAB
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
[vagrant@legacy-swarm-master ~]$ docker exec -it AContainer sh
/ # ping -c 3 10.1.1.2
PING 10.1.1.2 (10.1.1.2): 56 data bytes

--- 10.1.1.2 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss
/ # exit
```

### Chapter 2 - TCP Policy

In this section, we will create TCP deny policy as well as selective TCP port allow policy.

```

[vagrant@legacy-swarm-master ~]$ netctl policy rule-add -t TestTenant -d in --protocol tcp --port 0  --from-group epgA  --action deny policyAB 2
[vagrant@legacy-swarm-master ~]$ netctl policy rule-add -t TestTenant -d in --protocol tcp --port 8001  --from-group epgA  --action allow --priority 10 policyAB 3
[vagrant@legacy-swarm-master ~]$ netctl policy rule-ls -t TestTenant policyAB
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

[vagrant@legacy-swarm-master ~]$ docker exec -it BContainer sh
/ # iperf -s -p 8001
------------------------------------------------------------
Server listening on TCP port 8001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
```

On AContainer:

```
[vagrant@legacy-swarm-master ~]$ docker exec -it AContainer sh
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
[vagrant@legacy-swarm-master ~]$ netctl tenant create BandwidthTenant
Creating tenant: BandwidthTenant
[vagrant@legacy-swarm-master ~]$ netctl network create --tenant BandwidthTenant --subnet=50.1.1.0/24 --gateway=50.1.1.254 -p 1001 -e "vlan" BandwidthTestNet
Creating network BandwidthTenant:BandwidthTestNet
[vagrant@legacy-swarm-master ~]$ netctl group create -t BandwidthTenant BandwidthTestNet epgA
Creating EndpointGroup BandwidthTenant:epgA
[vagrant@legacy-swarm-master ~]$ netctl net ls -a
Tenant           Network           Nw Type  Encap type  Packet tag  Subnet       Gateway     IPv6Subnet  IPv6Gateway
------           -------           -------  ----------  ----------  -------      ------      ----------  -----------
BandwidthTenant  BandwidthTestNet  data     vlan        1001        50.1.1.0/24  50.1.1.254
[vagrant@legacy-swarm-master ~]$ netctl group ls -a
Tenant           Group  Network           IP Pool   Policies  Network profile
------           -----  -------           --------  ---------------
BandwidthTenant  epgA   BandwidthTestNet

```

Now, We are going to run serverA and clientA containers using group epgA as a network.


```
[vagrant@legacy-swarm-master ~]$ docker run -itd --net="epgA/BandwidthTenant" --name=serverA contiv/alpine sh
6112c6697df2c43491a23e02d3d8bc3f621b91d59c64226382789ba15082c71b
[vagrant@legacy-swarm-master ~]$ docker run -itd --net="epgA/BandwidthTenant" --name=clientA contiv/alpine sh
c783d6c3f546d6053953bd664045aa35397756656247255a7e0cbb4201b5514c
[vagrant@legacy-swarm-master ~]$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS               NAMES
f41c806565d3        contiv/alpine                "sh"                     6 seconds ago       Up 4 seconds                            legacy-swarm-worker0/clientA
7ea3a6a30e59        contiv/alpine                "sh"                     11 seconds ago      Up 9 seconds                            legacy-swarm-master/serverA
d50a96536aeb        contiv/alpine                "sh"                     6 minutes ago       Up 6 minutes                            legacy-swarm-worker0/BContainer
32e87214aedd        contiv/alpine                "sh"                     6 minutes ago       Up 6 minutes                            legacy-swarm-worker0/AContainer
654e678abd24        contiv/auth_proxy:1.0.3      "./auth_proxy --tls-k"   9 hours ago         Up 9 hours                              legacy-swarm-master/auth-proxy
e8f9f40077f1        quay.io/coreos/etcd:v2.3.8   "/etcd"                  9 hours ago         Up 9 hours                              legacy-swarm-worker0/etcd
7810f563e836        quay.io/coreos/etcd:v2.3.8   "/etcd"                  9 hours ago         Up 9 hours                              legacy-swarm-master/etcd

```

Now run iperf server and client to find out current bandwidth which we are getting on the network
where you are running this tutorial. It may vary depending upon base OS , network speed etc.


```
On serverA:

[vagrant@legacy-swarm-master ~]$ docker exec -it serverA sh
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

[vagrant@legacy-swarm-worker0 ~]$ export DOCKER_HOST=tcp://192.168.2.50:2375
[vagrant@legacy-swarm-worker0 ~]$ docker exec -it clientA sh
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
/ # exit

```

Now we see that, current bandwidth we are getting is 1.05 Mbits/sec.
So let us create new group B and create netprofile with bandwidth less than the one 
we got above. So let us create netprofile with bandwidth of 500Kbits/sec.

```

[vagrant@legacy-swarm-master ~]$ netctl netprofile create -t BandwidthTenant -b 500Kbps -d 6 -s 80 testProfile
Creating netprofile BandwidthTenant:testProfile
[vagrant@legacy-swarm-master ~]$ netctl group create -t BandwidthTenant -n testProfile BandwidthTestNet epgB
Creating EndpointGroup BandwidthTenant:epgB
[vagrant@legacy-swarm-master ~]$ netctl netprofile ls -a
Name         Tenant           Bandwidth  DSCP      burst size
------       ------           ---------  --------  ----------
testProfile  BandwidthTenant  500Kbps    6         80
[vagrant@legacy-swarm-master ~]$ netctl group ls -a
Tenant           Group  Network           IP Pool   Policies  Network profile
------           -----  -------           --------  ---------------
BandwidthTenant  epgA   BandwidthTestNet
BandwidthTenant  epgB   BandwidthTestNet              testProfile
[vagrant@legacy-swarm-master ~]$


```

Running clientB and serverB containers:

```

[vagrant@legacy-swarm-master ~]$ docker run -itd --net="epgB/BandwidthTenant" --name=serverB contiv/alpine sh
2f4845ed86c5496537ccece77683354e447c28df8f00c10a1a175eb5f44aee76
[vagrant@legacy-swarm-master ~]$ docker run -itd --net="epgB/BandwidthTenant" --name=clientB contiv/alpine sh
00dde4f46c360e517695e44f2690590ec0af26e125254102147fe79b76331339
[vagrant@legacy-swarm-master ~]$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS               NAMES
ce3004028e6e        contiv/alpine                "sh"                     4 seconds ago       Up 3 seconds                            legacy-swarm-worker0/clientB
9b229192cc8b        contiv/alpine                "sh"                     4 minutes ago       Up 4 minutes                            legacy-swarm-master/serverB
f41c806565d3        contiv/alpine                "sh"                     8 minutes ago       Up 8 minutes                            legacy-swarm-worker0/clientA
7ea3a6a30e59        contiv/alpine                "sh"                     8 minutes ago       Up 8 minutes                            legacy-swarm-master/serverA
d50a96536aeb        contiv/alpine                "sh"                     14 minutes ago      Up 14 minutes                           legacy-swarm-worker0/BContainer
32e87214aedd        contiv/alpine                "sh"                     15 minutes ago      Up 15 minutes                           legacy-swarm-worker0/AContainer
654e678abd24        contiv/auth_proxy:1.0.3      "./auth_proxy --tls-k"   9 hours ago         Up 9 hours                              legacy-swarm-master/auth-proxy
e8f9f40077f1        quay.io/coreos/etcd:v2.3.8   "/etcd"                  9 hours ago         Up 9 hours                              legacy-swarm-worker0/etcd
7810f563e836        quay.io/coreos/etcd:v2.3.8   "/etcd"                  9 hours ago         Up 9 hours                              legacy-swarm-master/etcd
[vagrant@legacy-swarm-master ~]$


```

Now as we are running clientB and serverB containers on group B network. we should see bandwidth around
500Kbps. Thats the verification that our bandwidth netprofile is working as per expectation.

```

On serverB:

[vagrant@legacy-swarm-master ~]$ docker exec -it serverB sh
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

[vagrant@legacy-swarm-worker0 ~]$ docker exec -it clientB sh
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
[vagrant@legacy-swarm-master ~]$ exit

$ make cluster-destroy
cd cluster && vagrant destroy -f
==> kubeadm-worker0: VM not created. Moving on...
==> kubeadm-master: VM not created. Moving on...
==> swarm-mode-worker0: VM not created. Moving on...
==> swarm-mode-master: VM not created. Moving on...
==> legacy-swarm-worker0: Forcing shutdown of VM...
==> legacy-swarm-worker0: Destroying VM and associated drives...
==> legacy-swarm-master: Forcing shutdown of VM...
==> legacy-swarm-master: Destroying VM and associated drives...

$ make vagrant-clean

```

### Improvements or Comments
This tutorial was developed by Contiv engineers. Thank you for trying out this tutorial.
Please file a GitHub issue if you see an issue with the tutorial, or if you prefer
improving some text, feel free to send a pull request.
