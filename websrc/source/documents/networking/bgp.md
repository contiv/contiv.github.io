---
layout: "documents"
page_title: "Physical network integration"
sidebar_current: "networking-physical-bgp"
description: |-
  Physical network integration
---

# Contiv in L3 Mode



Contiv supports L3, to enable:

-  Communication between containers on different hosts natively using VLAN encapsulation.
-  Communication between containers and non-containers.
-  Uplink TORs and leaf switches route to containers deployed in the fabric.

## Prerequisites

Contiv can be used in L3 mode with this build and later:

```
Version: v0.1-02-06-2016.14-42-05.UTC
GitCommit: 392e0a7
BuildTime: 02-06-2016.14-42-05.UTC
```

The following configuration details are required to use Contiv in L3 mode:

- Peering between the host server and the leaf switch is eBGP peering.
- Only one uplink from the server is supported.
- Only bare-metal nodes are supported.

Start the Contiv processes `netplugin` on all hosts and `netmaster` on one host.

See instructions [here](/documents/gettingStarted/networking/bgp.html) for a setup and installation process.

## Recommended Topologies

![topo](/assets/images/bgp_topology.png)

## Typical Workflow:
- Configure BGP on the leaf switches Leaf 1 and Leaf 2
- Add BGP configuration on the host, to peer with the uplink leaf
- Create a VLAN network with subnet pool and gateway
- Start containers in the networks created on the host

### Step 1 : Configure the Switches to run BGP

![bgp](/assets/images/bgp_arch.png)

The following sample configuration corresponds to the topology shown in the figure:

#### Switch1

```
router ospf 500
  router-id 80.1.1.1
router bgp 500
  router-id 50.1.1.2
  address-family ipv4 unicast
    redistribute direct route-map FH
    redistribute static route-map FH
    redistribute ospf 500 route-map FH
  neighbor 50.1.1.1 remote-as 65002
    remote-as 65002
    address-family ipv4 unicast
  neighbor 60.1.1.4 remote-as 500
    remote-as 500
    update-source Vlan1
    address-family ipv4 unicast

interface Ethernet1/44
  no switchport
  ip address 80.1.1.1/24
  ip router ospf 500 area 0.0.0.0

vlan 1
route-map FH permit 20
  match ip address HOSTS


interface Vlan1
  no shutdown
  ip address 50.1.1.2/24
  ip router ospf 500 area 0.0.0.0

ip access-list HOSTS
  10 permit ip any any
```

#### Switch 2

```
feature ospf
feature bgp
feature interface-vlan

router ospf 500
  router-id 80.1.1.2
router bgp 500
  router-id 60.1.1.4
  address-family ipv4 unicast
    redistribute direct route-map FH
    redistribute ospf 500 route-map FH
  neighbor 50.1.1.2 remote-as 500
    remote-as 500
    update-source Vlan1
    address-family ipv4 unicast
  neighbor 60.1.1.3 remote-as 65002
    remote-as 65002
    address-family ipv4 unicast

interface Ethernet1/44
  no switchport
  ip address 80.1.1.2/24
  ip router ospf 500 area 0.0.0.0

vlan 1
route-map FH permit 20
  match ip address HOSTS


interface Vlan1
  no shutdown
  ip address 60.1.1.4/24
  ip router ospf 500 area 0.0.0.0

ip access-list HOSTS
  10 permit ip any any

```

### Step 2: Add the BGP Neighbor on Each of the Contiv Hosts

On the host where netmaster is running:

```
$netctl bgp create Contiv1 -router-ip="50.1.1.1/24" --as="65002" --neighbor-as="500" --neighbor="50.1.1.2"
$netctl bgp create Contiv2 -router-ip="60.1.1.3/24" --as="65002" --neighbor-as="500" --neighbor="60.1.1.4"
```
where Contiv1 and Contiv2 are the hostnames of the servers shown in the topology.

### Step 3: Create Networks
Create a network with VLAN encapsulation and start containers in the network:

On the host where netmaster is running:

```
$netctl network create public --encap="vlan" --subnet=192.168.1.0/24 --gateway=192.168.1.254
```

On Contiv1 :

```
$docker run -itd --name=web1 --net=public alpine sh
```

On Contiv2 :

```
docker run -itd --name=web2 --net=public alpine sh
```

### Step 4: Verify IP Allocation, Routes, and Connectivity

Log in to the containers and verify the IP address has been allocated from the network.

```
$docker ps -a
CONTAINER ID        IMAGE                          COMMAND             CREATED              STATUS              PORTS               NAMES
084f47e72101        ubuntu                         "bash"              About a minute ago   Up About a minute                       web1
0cc23ada5578        skynetservices/skydns:latest   "/skydns"           6 minutes ago        Up 6 minutes        53/tcp, 53/udp      defaultdns


root@contiv1:~/# docker exec -it 084f47e72101 bash
root@084f47e72101:/# ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:c0:a8:01:03
          inet addr:192.168.1.3  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:c0ff:fea8:103/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:23 errors:0 dropped:0 overruns:0 frame:0
          TX packets:23 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2062 (2.0 KB)  TX bytes:2062 (2.0 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

Verify that the switches have the container routes:

```
Switch-1# show ip route
IP Route Table for VRF "default"
'*' denotes best ucast next-hop
'**' denotes best mcast next-hop
'[x/y]' denotes [preference/metric]
'%<string>' in via output denotes VRF <string>

50.1.1.0/24, ubest/mbest: 1/0, attached
    *via 50.1.1.2, Vlan1, [0/0], 3d23h, direct
50.1.1.2/32, ubest/mbest: 1/0, attached
    *via 50.1.1.2, Vlan1, [0/0], 3d23h, local
60.1.1.0/24, ubest/mbest: 1/0
    *via 80.1.1.2, Eth1/44, [110/44], 3d23h, ospf-500, intra
60.1.1.4/32, ubest/mbest: 1/0
    *via 80.1.1.2, [1/0], 1w3d, static
80.1.1.0/24, ubest/mbest: 1/0, attached
    *via 80.1.1.1, Eth1/44, [0/0], 1w3d, direct
80.1.1.1/32, ubest/mbest: 1/0, attached
    *via 80.1.1.1, Eth1/44, [0/0], 1w3d, local
192.168.1.1/32, ubest/mbest: 1/0
    *via 50.1.1.1, [20/0], 03:49:24, bgp-500, external, tag 65002
192.168.1.2/32, ubest/mbest: 1/0
    *via 60.1.1.3, [200/0], 00:00:02, bgp-500, internal, tag 65002
192.168.1.3/32, ubest/mbest: 1/0
    *via 50.1.1.1, [20/0], 03:47:08, bgp-500, external, tag 65002
```

Ping between the containers:

```
$root@084f47e72101:/# ping 192.168.1.2
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=62 time=9.29 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=62 time=0.156 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=62 time=0.139 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=62 time=0.130 ms
64 bytes from 192.168.1.2: icmp_seq=5 ttl=62 time=0.123 ms

```

Ping between container and a switch:

```
$root@084f47e72101:/# ping 80.1.1.2
PING 80.1.1.2 (80.1.1.2) 56(84) bytes of data.
64 bytes from 80.1.1.2: icmp_seq=1 ttl=254 time=0.541 ms
64 bytes from 80.1.1.2: icmp_seq=2 ttl=254 time=0.549 ms
64 bytes from 80.1.1.2: icmp_seq=3 ttl=254 time=0.551 ms
64 bytes from 80.1.1.2: icmp_seq=4 ttl=254 time=0.562 ms
64 bytes from 80.1.1.2: icmp_seq=5 ttl=254 time=0.484 ms
```


##Policy support

For steps to apply policies supported in contiv networking. Please follow the steps in [Contiv Policies]

[Contiv Policies]: </documents/networking/policies.html>
