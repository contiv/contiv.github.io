---
layout: "documents"
page_title: "Networking IPAM"
sidebar_current: "networking-ipam"
description: |-
  Networking IPAM
---

## IP Address Management
Contiv network allocates a unique IP address for every container. IP address allocated to a container is not bound to an application group or microservice tier. Every container simply gets an IP address from the subnet pool. Unlike some of the container networking solutions that require a subnet per host, contiv solution does not have such limitations. This also makes contiv solution truly multi-tenant. You can have overlapping IP addresses across tenants.

#### Subnet IP Pool

You can specify the IP address pool to be used for a network using `-subnet` argument while creating the network. You can specify the entire CIDR range or just a smaller range.

```
$ netctl net create contiv-net -subnet 10.1.1.50-100/24
```

In this example, `contiv-net` has a smaller IP address pool from address `10.1.1.50` to `10.1.1.100`.
If you run a container in `contiv-net`, it'll get an IP address from this smaller ip address pool.

```
$ docker run -itd --net contiv-net --name app1 alpine sh
c33f5920074e0807db442a65238fdc77018e6ad553022e78ac51509f74cedf49
$ docker exec -it app1 sh
/ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:01:34  
          inet addr:10.1.1.52  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:134%32588/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

/ #
```


## Service Discovery

Contiv network provides built in service discovery for all containers in the network. Unlike traditional service discovery tools which require applications to query external KV stores for container IP/port information, contiv service discovery uses standard DNS protocol and requires no changes to the application.

When a container is attached to an endpoint group, it automatically becomes reachable by DNS name. For example, we ran a container and attached it to `production-web` endpoint group. This container becomes available by DNS name `production-web` for all other containers in the same tenant. If there are multiple containers in same endpoint group, all of them would be available by same DNS service name. DNS queries will be load balanced across all containers in the group.

Similarly, all service loadbalancers created using contiv would be available for DNS query by service name too.
