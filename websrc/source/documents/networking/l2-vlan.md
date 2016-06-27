---
layout: "documents"
page_title: "Networking concepts"
sidebar_current: "networking-physical-l2"
description: |-
  Networking concepts
---

##Contiv in L2 Mode

This page contains the steps to use Contiv in L2 mode.

![L2](contiv-l2-mode.png)


#Typical Workflow:

- Bring up Contiv – netplugin and netmaster
- Create a Vlan network with subnet pool and gateway
- Configure SVIs on switches
- Bring up containers in the networks created on the host

#Supported Version:

```
Version: v0.1-02-06-2016.14-42-05.UTC
GitCommit: 392e0a7
BuildTime: 02-06-2016.14-42-05.UTC
```

#STEP 1: Configure Switches:

Need to configure vlans (probably as a SVIs) in a following manner.

```
interface Vlan10
  no shutdown
  ip address 10.1.1.1/24

interface Vlan11
  no shutdown
  ip address 11.1.1.1/24

interface Vlan12
  no shutdown
  ip address 12.1.1.1/24

```

#STEP 2: Create Network:

Need to create network with encap as Vlan and packet tag as VlandID and Start containers in Network.

```
netctl network create demo1-net1 -s 10.1.1.0/24 -g 10.1.1.1 --pkt-tag 10 --encap vlan
netctl network create demo1-net2 -s 11.1.1.0/24 -g 11.1.1.1 --pkt-tag 11 --encap vlan
netctl network create demo1-net2 -s 12.1.1.0/24 -g 12.1.1.1 --pkt-tag 12 --encap vlan
```

#STEP 3: Log in to containers and verify the IP address has been allocated from the network
```
docker ps
CONTAINER ID        IMAGE                          COMMAND             CREATED             STATUS              PORTS               NAMES
049a85ec0c8c        alpine                         "sh"                7 minutes ago       Up 7 minutes                            contiv-demo-swarm-l2-4/desperate_bose
f864841d626d        alpine                         "sh"                8 minutes ago       Up 8 minutes                            contiv-demo-swarm-l2-6/agitated_brahmagupta
9f3aed39e95b        alpine                         "sh"                9 minutes ago       Up 8 minutes                            contiv-demo-swarm-l2-6/happy_pasteur
a3111bb0c9e1        quay.io/coreos/etcd:v2.3.1     "/etcd"             10 minutes ago      Up 10 minutes                           contiv-demo-swarm-l2-4/etcd
6881c4c1b380        quay.io/coreos/etcd:v2.3.1     "/etcd"             10 minutes ago      Up 10 minutes                           contiv-demo-swarm-l2-6/etcd
a8eb4c23c009        quay.io/coreos/etcd:v2.3.1     "/etcd"             10 minutes ago      Up 10 minutes                           contiv-demo-swarm-l2-5/etcd
b54850f408d8        skynetservices/skydns:latest   "/skydns"           5 weeks ago         Up 10 minutes       53/tcp, 53/udp      contiv-demo-swarm-l2-6/defaultdns
b54850f408d8        skynetservices/skydns:latest   "/skydns"           5 weeks ago         Up 10 minutes       53/tcp, 53/udp      contiv-demo-swarm-l2-4/defaultdns
b54850f408d8        skynetservices/skydns:latest   "/skydns"           5 weeks ago         Up 10 minutes       53/tcp, 53/udp      contiv-demo-swarm-l2-5/defaultdns
[admin@contiv-demo-swarm-l2-4 ~]$ docker exec -it 049a85ec0c8c sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:0C:01:01:02  
          inet addr:12.1.1.2  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:cff:fe01:102%32624/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:13 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1062 (1.0 KiB)  TX bytes:1124 (1.0 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32624/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:168 (168.0 B)  TX bytes:168 (168.0 B)
```


#STEP 4: Verify that switch has the container routes
```
sh ip arp

Flags: * - Adjacencies learnt on non-active FHRP router
       + - Adjacencies synced via CFSoE
       # - Adjacencies Throttled for Glean
       D - Static Adjacencies attached to down interface

IP ARP Table for context
Total number of entries: 3
Address         Age       MAC Address     Interface
10.1.1.2        00:00:19  0202.0a01.0102  Vlan10          
11.1.1.2        00:00:23  0202.0b01.0102  Vlan11          
12.1.1.2        00:00:23  0202.0c01.0102  Vlan12    
```

#STEP 5: Ping between containers

From container having IP 11.1.1.2

```
ping 10.1.1.2
PING 10.1.1.2 (10.1.1.2): 56 data bytes
64 bytes from 10.1.1.2: seq=0 ttl=63 time=2.909 ms
64 bytes from 10.1.1.2: seq=1 ttl=63 time=0.833 ms
^C
--- 10.1.1.2 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.833/1.871/2.909 ms
```
From container having IP 10.1.1.2

```
ping 11.1.1.2
PING 11.1.1.2 (11.1.1.2): 56 data bytes
64 bytes from 11.1.1.2: seq=0 ttl=63 time=1.123 ms
64 bytes from 11.1.1.2: seq=1 ttl=63 time=0.756 ms
64 bytes from 11.1.1.2: seq=2 ttl=63 time=1.181 ms
^C
--- 11.1.1.2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.756/1.020/1.181 ms
```

#Policy Support
For steps to apply policies supported in contiv networking. Please follow the steps in [Contiv Policies]


[Contiv Policies]: </documents/networking/policies.html>
