---
layout: "documents"
page_title: "Container Networking Tutorial"
sidebar_current: "tutorials-container-101"
description: |-
  Container Networking Tutorial
---

# Container Networking Tutorial

This tutorial is a set of step-by-step container networking examples.
It introduces many of the key concepts in how to network containerized applications.

## Chapter 0: Software Setup
This tutorial requires a virtual machine (VM) software environment and the
installation of several tools. The tools and environment are easy to set
up using the procedures in this chapter. 

You can install the tutorial environment on a Linux, OS X, or Windows computer.

### Prerequisites 
Before you begin, install Vagrant and VirtualBox:

- [Download Vagrant](https://www.vagrantup.com/downloads.html)
- [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)

If you plan to run the tutorial on Windows, download and install
an ssh client such as *putty* or *Cygwin*. 

### Setup
The following steps describe how to set up and start a container cluster.

#### Step 1: Download the Vagrant Setup
Copy the contents of 
[this file](https://raw.githubusercontent.com/jainvipin/tutorial/master/Vagrantfile) into a file called Vagrantfile. 
On Linux and OS X machines, you can use *curl*, as follows:

```
$ curl https://raw.githubusercontent.com/jainvipin/tutorial/master/Vagrantfile -o Vagrantfile
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6731  100  6731    0     0   8424      0 --:--:-- --:--:-- --:--:--  8424
```

On Windows the file might download  with `.txt` extension. If necessary, rename the file
to remove the `.txt` extension. A way to change the Windows file extension
[is documented here](http://www.mediacollege.com/microsoft/windows/extension-change.html).

#### Step 2: Create a `resolv.conf` File
In the directory where you copied the Vagrantfile, create a `resolv.conf` file.
Throughout the rest of this tutorial, this file is used by VMs to access an outside network 
for downloading Docker images.

```
$ cp /etc/resolv.conf .

$ cat resolv.conf
domain my_example_domain.com
nameserver 171.70.168.183
nameserver 173.36.131.10
```

Verify that your directory contains the `Vagrantfile` and the `resolv.conf` file:

$ ls
Vagrantfile	resolv.conf
```

#### Step 3: Start a Two-node Cluster

In the directory containing the `Vagrantfile`, start the tutorial VM cluster
by typing `vagrant up`:

```
$ vagrant up
Bringing machine 'tutorial-node1' up with 'virtualbox' provider...
Bringing machine 'tutorial-node2' up with 'virtualbox' provider...
 < more output here when trying to bring up the two VMs>
==> tutorial-node2: ++ nohup /opt/bin/start-swarm.sh 192.168.2.11 slave
$
```

#### Step 4: Inspect the VM Services and Utilities

Next, log into one of the VMs and familiarize yourself with some of the
services and utilities that have been installed for the tutorial. This also confirms
that the services are installed and running properly. 

Log into one of the VMs as follows (The username/password for the VMs is vagrant/vagrant):

```
$ vagrant ssh tutorial-node1
```

The prompt changes, indicating that you are logged into a shell on the VM.

The following command shows some information about Docker services on the node.

```
vagrant@tutorial-node1:~$ docker info
```

Next, look at  `etcdctl`, a control utility to manipulate the *etcd*.
The *etcd* service is a state store that is used by many of the network 
and container services, including Kubernetes, Docker, and Contiv. Type
the following:

```
vagrant@tutorial-node1:~$ etcdctl cluster-health
```

Now look at the network interfaces on the VM:

```
vagrant@tutorial-node1:~$ ifconfig docker0
docker0   Link encap:Ethernet  HWaddr 02:42:fb:53:27:56  
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:fbff:fe53:2756/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:3521 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3512 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:178318 (178.3 KB)  TX bytes:226978 (226.9 KB)

vagrant@tutorial-node1:~$ ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 08:00:27:f7:17:75  
          inet addr:192.168.2.10  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fef7:1775/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:219585 errors:0 dropped:0 overruns:0 frame:0
          TX packets:272864 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:21413163 (21.4 MB)  TX bytes:28556948 (28.5 MB)

vagrant@tutorial-node1:~$ ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 08:00:27:a2:bc:0d  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fea2:bc0d/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:28103 errors:0 dropped:0 overruns:0 frame:0
          TX packets:13491 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:36213596 (36.2 MB)  TX bytes:858264 (858.2 KB)
```

Notice the following:

- The `docker0` interface corresponds to the linux bridge and its associated
subnet `172.17.0.1/16`. This is created by the Docker daemon automatically, and
is the default network containers belong to when no network is explicitly specified.
- `eth0` in this VM is the management interface, which we used to connect to the VM with ssh.
- `eth1` in this VM is the interface used to connect to an external network (if needed).
- `eth2` in this VM is the interface that carries vxlan and control (for example, etcd) traffic.

Next, check the version of the Contiv Network utility:

```
vagrant@tutorial-node1:~$ netctl version
```

`netctl` is a utility to create, update, read and modify Contiv objects. The *netctl*
utility is a command-line interface (CLI) wrapper over the Contiv Network REST interface.

#### How to Restart
You can reset the VM cluster if the VM is shut down or restarted, or if connectivity is lost.
Then, restart the tutorial from where you left at the beginning of the chapter.

To reset, type `vagrant -f destroy` to clean up and stop the cluster,
then restart again by typing `vagrant up`.

## Chapter 1 - Introduction to Container Networking

The container community recognized two main container networking models, the
Container Network Model (CNM) and the Container Network Interface (CNI).

### Docker libnetwork - The Container Network Model

Container Network Model (CNM) is Docker's *libnetwork* network model for containers.
It has the following features:

- An endpoint is container's interface into a network.
- A network is collection of arbitrary endpoints.
- A container can belong to multiple endpoints (and therefore multiple networks).
- CNM allows for co-existence of multiple drivers, with a network managed by one driver.
- The model provides Driver APIs for IP address management (IPAM) and endpoint creation and deletion.
- The IPAM Driver APIs are: Create/Delete Pool, Allocate/Free IP Address.
- The Network Driver APIs are: Network Create/Delete, Endpoint Create/Delete/Join/Leave.
- Used by Docker Engine, Docker Swarm, and Docker Compose Also used by other schedulers that schedule regular Docker containers, for example  Nomad or Mesos Docker Containerizer.

### CoreOS CNI - Container Network Interface 
Container Network Interface (CNI) is CoreOS's network model for containers. 
It has the following features:

- Allows specifying container id (uuid) for which a network interface is created. 
- Provides container Create/Delete events.
- Provides the driver with access to the network namespace to plumb networking.
- Provides no separate IPAM Driver: Container Create returns the IAPM information along with other data.
- Used by Kubernetes and supported by various Kubernet network plugins, including Contiv.

[Click here](https://github.com/contiv/netplugin/tree/master/mgmtfn/k8splugin) to read more about using Contiv with CNI and Kubernetes.

The examples throughout the rest of this tutorial use Docker, which implements the CNM APIs.

#### Basic Container Networking

Let's examine the networking supplied with a "plain vanilla" basic container. 
In the Docker VM, type to commands shown:

```
vagrant@tutorial-node1:~$ docker network ls
NETWORK ID          NAME                DRIVER
3c5ec5bc780a        none                null                
fb44f53e1e91        host                host                
6a63b892d974        bridge              bridge              

vagrant@tutorial-node1:~$ docker run -itd --name=vanilla-c alpine /bin/sh
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
b66121b7b9c0: Pull complete 
Digest: sha256:9cacb71397b640eca97488cf08582ae4e4068513101088e9f96c9814bfda95e0
Status: Downloaded newer image for alpine:latest
2cf083c0a4de1347d8fea449dada155b7ef1c99f1f0e684767ae73b3bbb6b533
 
vagrant@tutorial-node1:~$ ifconfig 
```

In the `ifconfig` output, notice the creation of a veth `virtual 
ethernet interface` that looks something like `veth......` towards the end. More 
importantly, it is allocated an IP address from the default docker bridge `docker0`, 
probably `172.17.0.3` in this setup. Examine the bridge as follows:

```
vagrant@tutorial-node1:~$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "6a63b892d97413275ab32e8792d32498848ad32bfb78d3cfd74a82ce5cbc46c2",
        "Scope": "local",
        "Driver": "bridge",
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "172.17.0.1/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Containers": {
            "2cf083c0a4de1347d8fea449dada155b7ef1c99f1f0e684767ae73b3bbb6b533": {
                "EndpointID": "c0cebaaf691c3941fca1dae4a8d2b3a94c511027f15d4c27b40606f7fb937f24",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            },
            "ab353464b4e20b0267d6a078e872fd21730242235667724a9147fdf278a03220": {
                "EndpointID": "6259ca5d2267f02d139bbcf55cb15b4ad670edefb5f4308e47da399beb1dc62c",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        }
    }
]
```

See just the IP address like this:

```
vagrant@tutorial-node1:~$ docker inspect --format '{{.NetworkSettings.IPAddress}}' vanilla-c
172.17.0.3
```

The other pair of veth interfaces are added to the container with the name `eth0`:

```
vagrant@tutorial-node1:~$ docker exec -it vanilla-c /bin/sh
/ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:03  
          inet addr:172.17.0.3  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:3%32577/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)
/ # exit
```

All traffic to and from this container is port-NATed to the host's IP (on eth0).
The Port NATing on the host is done using iptables, which can be seen as a
MASQUERADE rule for outbound traffic for `172.17.0.0/16`:

```
$ vagrant@tutorial-node1:~$ sudo iptables -t nat -L -n
```

## Chapter 2: Multi-Host Networking

There are many products that provide solutions for multi-host container networking. 
These include Contiv, Calico, Weave, Openshift, OpenContrail, Nuage, VMWare, Docker, 
Kubernetes, and Openstack. In this section we examine Contiv and Docker overlay solutions.

### Multi-Host Networking with Contiv
Create two containers on the two different hosts. This requires three steps.

First, do the following to create and examine a new virtual network called `contiv-net`:

```
vagrant@tutorial-node1:~$ netctl net create --subnet=10.1.2.0/24 contiv-net
vagrant@tutorial-node1:~$ netctl net ls
Tenant   Network     Nw Type  Encap type  Packet tag  Subnet       Gateway
------   -------     -------  ----------  ----------  -------      ------
default  contiv-net  data     vxlan       0           10.1.2.0/24  

vagrant@tutorial-node1:~$ docker network ls
NETWORK ID          NAME                DRIVER
22f79fe02239        overlay-net         overlay             
af2ed0437304        contiv-net          netplugin           
6a63b892d974        bridge              bridge              
3c5ec5bc780a        none                null                
fb44f53e1e91        host                host                
cf7ccff07b64        docker_gwbridge     bridge              

vagrant@tutorial-node1:~$ docker network inspect contiv-net
[
    {
        "Name": "contiv-net",
        "Id": "af2ed043730432e383bbe7fc7716cdfee87246f96342a320ef5fa99f8cf60312",
        "Scope": "global",
        "Driver": "netplugin",
        "IPAM": {
            "Driver": "netplugin",
            "Config": [
                {
                    "Subnet": "10.1.2.0/24"
                }
            ]
        },
        "Containers": {
            "ab353464b4e20b0267d6a078e872fd21730242235667724a9147fdf278a03220": {
                "EndpointID": "5d1720e71e3a4c8da6a8ed361480c094aeb6a3cd3adfe0c7b185690bc64ddcd9",
                "MacAddress": "",
                "IPv4Address": "10.1.2.2/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "encap": "vxlan",
            "pkt-tag": "1",
            "tenant": "default"
        }
    }
]
```

Second, run a new container belonging to the `contiv-net` network:

```
vagrant@tutorial-node1:~$ docker run -itd --name=contiv-c1 --net=contiv-net alpine /bin/sh
46e619b0b418107114e93f9814963d5c351835624e8da54100b0707582c69549
```

Finally, use ssh to log into the second node using `vagrant ssh tutorial-node2`, create a
new container on it, and try to reach another container running on `tutorial-node1`:

```
vagrant@tutorial-node2:~$ docker run -itd --name=contiv-c2 --net=contiv-net alpine /bin/sh
26b9f22b9790b55cdfc85f1c2779db5d5fc78c18fee1ea088b85ec0883361a72

vagrant@tutorial-node2:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                  PORTS               NAMES
26b9f22b9790        alpine              "/bin/sh"           2 seconds ago       Up Less than a second                       contiv-c2

vagrant@tutorial-node2:~$ docker exec -it contiv-c2 /bin/sh

/ # ping contiv-c1
PING contiv-c1 (10.1.2.3): 56 data bytes
64 bytes from 10.1.2.3: seq=0 ttl=64 time=6.596 ms
64 bytes from 10.1.2.3: seq=1 ttl=64 time=9.451 ms
^C
--- contiv-c1 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 6.596/8.023/9.451 ms

/ # exit
```

The `ping` command demonstrates that built-in DNS resolves the name `overlay-c1`
to the IP address of the `overlay-c1` container. The container `contiv-c2` is
ableto reach the container on the other VM across the network using a vxlan overlay.

### Docker Overlay Multi-host Networking

Docker engine has a built in overlay driver that can be use to connect
containers across multiple nodes. 

Create another network as follows:

```
vagrant@tutorial-node1:~$ docker network create -d=overlay --subnet=10.1.1.0/24 overlay-net
22f79fe02239d3cbc2c8a4f7147f0e799dc13f3af6e46a69cc3adf8f299a7e56

vagrant@tutorial-node1:~$ docker network inspect overlay-net
[
    {
        "Name": "overlay-net",
        "Id": "22f79fe02239d3cbc2c8a4f7147f0e799dc13f3af6e46a69cc3adf8f299a7e56",
        "Scope": "global",
        "Driver": "overlay",
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "10.1.1.0/24"
                }
            ]
        },
        "Containers": {},
        "Options": {}
    }
]
```

Now create a container that belongs to `overlay-net`:

```
vagrant@tutorial-node1:~$ docker run -itd --name=overlay-c1 --net=overlay-net alpine /bin/sh
0ab717006962fb2fe936aa3c133dd27d68c347d5f239f473373c151ad4c77b28

vagrant@tutorial-node1:~$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' overlay-c1
10.1.1.2
```

As before, run another container belonging to the same network within the cluster and
make sure that they can reach each other.

```
vagrant@tutorial-node1:~$ docker run -itd --name=overlay-c2 --net=overlay-net alpine /bin/sh
0a6f43693361855ad56cda417b9ec63f504de4782ac82f0181fed92d803b4a30
vagrant@tutorial-node1:~$ docker ps
CONTAINER ID        IMAGE                          COMMAND             CREATED             STATUS              PORTS               NAMES
fb822eda9916        alpine                         "/bin/sh"           3 minutes ago       Up 3 minutes                            overlay-c2
0ab717006962        alpine                         "/bin/sh"           21 minutes ago      Up 21 minutes                           overlay-c1
2cf083c0a4de        alpine                         "/bin/sh"           28 minutes ago      Up 28 minutes                           vanilla-c
ab353464b4e2        skynetservices/skydns:latest   "/skydns"           33 minutes ago      Up 33 minutes       53/tcp, 53/udp      defaultdns

vagrant@tutorial-node2:~$ docker exec -it overlay-c2 /bin/sh
/ # ping overlay-c1
PING overlay-c1 (10.1.1.2): 56 data bytes
64 bytes from 10.1.1.2: seq=0 ttl=64 time=0.066 ms
64 bytes from 10.1.1.2: seq=1 ttl=64 time=0.092 ms
^C
--- overlay-c1 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.066/0.079/0.092 ms

/ # exit
```

Similar to the contiv-networking example, built-in DNS resolves the name `overlay-c1`
to the IP address of the `overlay-c1` container and one container can reach the other container
across using a vxlan overlay.

## Chapter 3: Multiple Tenants, Arbitrary IPs. 

Now we add multiple tenants with arbitrary IPs in their networks.

First, create a new tenant space:

```
vagrant@tutorial-node1:~$ netctl tenant create blue
INFO[0000] Creating tenant: blue                    

vagrant@tutorial-node1:~$ netctl tenant ls 
Name     
------   
default  
blue     
```

After the tenant is created, you can create a network within tenant `blue` and run containers.
Do so, using the same subnet and network name as in the previous exercise:

```
vagrant@tutorial-node1:~$ netctl net create -t blue --subnet=10.1.2.0/24 contiv-net
vagrant@tutorial-node1:~$ netctl net ls -t blue
Tenant  Network     Nw Type  Encap type  Packet tag  Subnet       Gateway
-/-----  -------     -------  ----------  ----------  -------      ------
blue    contiv-net  data     vxlan       0           10.1.2.0/24  
```

Next, run containers belonging to this tenant:

```
vagrant@tutorial-node1:~$ docker run -itd --name=contiv-blue-c1 --net=contiv-net/blue alpine /bin/sh
6c7d8c0b14ec6c2c9f52468faf50444e29c4b1fa61753b75c00f033564814515

vagrant@tutorial-node1:~$ docker ps
CONTAINER ID        IMAGE                          COMMAND             CREATED             STATUS              PORTS               NAMES
6c7d8c0b14ec        alpine                         "/bin/sh"           8 seconds ago       Up 6 seconds                            contiv-blue-c1
17afcd58b8fc        skynetservices/skydns:latest   "/skydns"           6 minutes ago       Up 6 minutes        53/tcp, 53/udp      bluedns
46e619b0b418        alpine                         "/bin/sh"           11 minutes ago      Up 11 minutes                           contiv-c1
fb822eda9916        alpine                         "/bin/sh"           23 minutes ago      Up 23 minutes                           overlay-c2
0ab717006962        alpine                         "/bin/sh"           41 minutes ago      Up 41 minutes                           overlay-c1
2cf083c0a4de        alpine                         "/bin/sh"           48 minutes ago      Up 48 minutes                           vanilla-c
ab353464b4e2        skynetservices/skydns:latest   "/skydns"           53 minutes ago      Up 53 minutes       53/udp, 53/tcp      defaultdns
```

Run a couple more containers in the host `tutorial-node2` that belong to the tenatn `blue`:

```
vagrant@tutorial-node2:~$ docker run -itd --name=contiv-blue-c2 --net=contiv-net/blue alpine /bin/sh
521abe19d6b5b3557de6ee4654cc504af0c497a64683f737ffb6f8238ddd6454
vagrant@tutorial-node2:~$ docker run -itd --name=contiv-blue-c3 --net=contiv-net/blue alpine /bin/sh
0fd07b44d042f37069f9a2f7c901867e8fd01c0a5d4cb761123e54e510705c60
vagrant@tutorial-node2:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
0fd07b44d042        alpine              "/bin/sh"           7 seconds ago       Up 5 seconds                            contiv-blue-c3
521abe19d6b5        alpine              "/bin/sh"           23 seconds ago      Up 21 seconds                           contiv-blue-c2
26b9f22b9790        alpine              "/bin/sh"           13 minutes ago      Up 13 minutes                           contiv-c2

vagrant@tutorial-node2:~$ docker network inspect contiv-net/blue
[
    {
        "Name": "contiv-net/blue",
        "Id": "4b8448967b7908cab6b3788886aaccc2748bbd85251258de3d01f64e5ee7ae68",
        "Scope": "global",
        "Driver": "netplugin",
        "IPAM": {
            "Driver": "netplugin",
            "Config": [
                {
                    "Subnet": "10.1.2.0/24"
                }
            ]
        },
        "Containers": {
            "0fd07b44d042f37069f9a2f7c901867e8fd01c0a5d4cb761123e54e510705c60": {
                "EndpointID": "4688209bd46047f1e9ab016fadff7bdf7c012cbfa253ec6a3661742f84ca5feb",
                "MacAddress": "",
                "IPv4Address": "10.1.2.4/24",
                "IPv6Address": ""
            },
            "521abe19d6b5b3557de6ee4654cc504af0c497a64683f737ffb6f8238ddd6454": {
                "EndpointID": "4d9ca7047b8737b78f271a41db82bbf5c3004f297211d831af757f565fc0c691",
                "IPv4Address": "10.1.2.3/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "encap": "vxlan",
            "pkt-tag": "2",
            "tenant": "blue"
        }
    }
]

vagrant@tutorial-node2:~$ docker exec -it contiv-blue-c3 /bin/sh
/ # ping contiv-blue-c1
PING contiv-blue-c1 (10.1.2.2): 56 data bytes
64 bytes from 10.1.2.2: seq=0 ttl=64 time=60.414 ms
^C
--- contiv-blue-c1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 60.414/60.414/60.414 ms
/ # ping contiv-blue-c2
PING contiv-blue-c2 (10.1.2.3): 56 data bytes
64 bytes from 10.1.2.3: seq=0 ttl=64 time=1.637 ms
^C
--- contiv-blue-c2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 1.637/1.637/1.637 ms

/ # exit
```

As expected, the containers are reachable to each other. 

### Chapter 4: Connecting Containers to External Networks

In this chapter, we explore ways to connect containers to external networks.

#### External Connectivity using Host NATing

Docker uses the Linux bridge (docker_gwbridge)-based PNAT to reach out. 
It uses port mappings to enable others to reach the container.

```
vagrant@tutorial-node1:~$ docker exec -it contiv-c1 /bin/sh
/ # ifconfig -a
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:02:03  
          inet addr:10.1.2.3  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:203%32627/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:19 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1534 (1.4 KiB)  TX bytes:886 (886.0 B)

eth1      Link encap:Ethernet  HWaddr 02:42:AC:12:00:04  
          inet addr:172.18.0.4  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe12:4%32627/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:32 errors:0 dropped:0 overruns:0 frame:0
          TX packets:27 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:5584 (5.4 KiB)  TX bytes:3344 (3.2 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32627/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # ping contiv.com
PING contiv.com (216.239.34.21): 56 data bytes
64 bytes from 216.239.34.21: seq=0 ttl=61 time=35.941 ms
64 bytes from 216.239.34.21: seq=1 ttl=61 time=38.980 ms
^C
--- contiv.com ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 35.941/37.460/38.980 ms

/ # exit
```

Notice that the container has two interfaces: 

- eth0 connects into the `contiv-net` 
- eth1 connects the container to the external world and enables outside traffic to reach the container `contiv-c1`. This connectivity also relies on the host's DNS `resolv.conf` for default non-container IP resolution.

Similarly, outside traffic can be exposed on specific ports using `-p` command. 

First,confirm that port 9099 is not reachable from the host `tutorial-node1`:

```
vagrant@tutorial-node1:~$ nc -zvw 1 localhost 9099
nc: connect to localhost port 9099 (tcp) failed: Connection refused
nc: connect to localhost port 9099 (tcp) failed: Connection refused
```

Now start a container that exposes TCP port 9099 out in the host.

```
vagrant@tutorial-node1:~$ docker run -itd -p 9099:9099 --name=contiv-exposed --net=contiv-net alpine /bin/sh
```

Re-run the `nc` utility, and note that port 9099 is reachable:

```
vagrant@tutorial-node1:~$ nc -zvw 1 localhost 9099
Connection to localhost 9099 port [tcp/*] succeeded!
```

This happens because in Docker as soon as a port is exposed, a NAT rule is installed that
allows the rest of the network to access the container on the newly exposed
port. Examine the NAT rule like this:

```
vagrant@tutorial-node1:~$ sudo iptables -t nat -L -n
iptables v1.4.21: can't initialize iptables table `nat': Permission denied (you must be root)
Perhaps iptables or your kernel needs to be upgraded.
vagrant@tutorial-node1:~$ sudo iptables -t nat -L -n
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
MASQUERADE  all  --  172.18.0.0/16        0.0.0.0/0           
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0           
MASQUERADE  tcp  --  172.18.0.6           172.18.0.6           tcp dpt:9099

Chain DOCKER (2 references)
target     prot opt source               destination         
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9099 to:172.18.0.6:9099

```

### Natively Connecting to External Networks

Remote drivers like Contiv provide an easy way to connect to external
layer 2 or layer 3 networks using BGP or standard L2 access into the network.

This can be done Using a BGP hand-off to the leaf or top-of-rack (TOR) switch. 
[Click here](/install/user_guide/getting_started/networking/bgp.html) for
an example that describes how you can use BGP with Contiv to provide native 
container connectivity and reachability to rest of the network. 

For this tutorial, since we don't have a real or simulated BGP router, 
we'll use some very simple native L2 connectivity to show the power of native connectivity. 

Start by creating a VLAN network:

```
vagrant@tutorial-node1:~$ netctl net create -p 112 -e vlan -s 10.1.3.0/24 contiv-vlan
vagrant@tutorial-node1:~$ netctl net ls
Tenant   Network         Nw Type  Encap type  Packet tag  Subnet       Gateway
------   -------         -------  ----------  ----------  -------      ------
default  contiv-net      data     vxlan       0           10.1.2.0/24  
default  contiv-vlan     data     vlan        112         10.1.3.0/24  
```

The VLAN can be used to connect any workload in VLAN 112 in the network infrstructure.
The interface that connects to the outside network must be specified during netplugin
start; for this VM configuration it is set as `eth2`.

Run some containers to belong to this network, one on each node. Create the first on
`tutorial-node1`:

```
vagrant@tutorial-node1:~$ docker run -itd --name=contiv-vlan-c1 --net=contiv-vlan alpine /bin/sh
4bf58874c937e242b4fc2fd8bfd6896a7719fd10475af96e065a83a2e80e9e48
```

And the second on `tutorial-node2`:

```
vagrant@tutorial-node2:~$ docker run -itd --name=contiv-vlan-c2 --net=contiv-vlan alpine /bin/sh
1c463ecad8295b112a7556d1eaf35f1a8152c6b8cfcef1356d40a7b015ae9d02

vagrant@tutorial-node2:~$ docker exec -it contiv-vlan-c2 /bin/sh

/ # ping contiv-vlan-c1
PING contiv-vlan-c1 (10.1.3.4): 56 data bytes
64 bytes from 10.1.3.4: seq=0 ttl=64 time=2.431 ms
64 bytes from 10.1.3.4: seq=1 ttl=64 time=1.080 ms
64 bytes from 10.1.3.4: seq=2 ttl=64 time=1.022 ms
64 bytes from 10.1.3.4: seq=3 ttl=64 time=1.048 ms
64 bytes from 10.1.3.4: seq=4 ttl=64 time=1.119 ms
. . .
```

While the `ping` runs on `tutorial-node2`, run `tcpdump` on eth2 on `tutorial-node1`
and look at the rx/tx packets: 

```
vagrant@tutorial-node1:~$ sudo tcpdump -e -i eth2 icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), capture size 262144 bytes
05:16:51.578066 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:04 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.4: ICMP echo request, id 2816, seq 294, length 64
05:16:52.588159 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:04 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.4: ICMP echo request, id 2816, seq 295, length 64
05:16:53.587408 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:04 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.4: ICMP echo request, id 2816, seq 296, length 64
05:16:54.587550 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:04 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.4: ICMP echo request, id 2816, seq 297, length 64
ç05:16:55.583786 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:04 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.4: ICMP echo request, id 2816, seq 298, length 64
^C
5 packets captured
```

Note that the VLAN shown in `tcpdump` is same (`112`) as you configured in the VLAN. 
After verifying this, stop the ping that is still running on `contiv-vlan-c2`.

## Chapter 5: Applying Policies Between Containers with Contiv

Contiv provide a way to apply isolation policies between containers groups.
To demonstrate, create a simple policy called db-policy, and add some rules to 
which ports are allowed.

Start with `tutorial-node1` and create the `contiv-net` (if you have restarted
the environment after the previous exercise).

```
vagrant@tutorial-node1:~$ netctl net create --subnet=10.1.2.0/24 contiv-net
```

Next, create a policy called `db-policy` to be applied to all db containers.

```
vagrant@tutorial-node1:~$ netctl policy create db-policy
INFO[0000] Creating policy default:db-policy
vagrant@tutorial-node1:~$ netctl policy ls
Tenant   Policy
------   ------
default  db-policy
```

Populate the policy with some rules:

```
vagrant@tutorial-node1:~$ netctl policy rule-add db-policy 1 -direction=in -protocol=tcp -action=deny
vagrant@tutorial-node1:~$ netctl policy rule-add db-policy 2 -direction=in -protocol=tcp -port=8888 -action=allow -priority=10
vagrant@tutorial-node1:~$ netctl policy rule-ls db-policy
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1                                                           tcp       0     deny
2     10                                                          tcp       8888  allow
Outgoing Rules:
Rule  Priority  To EndpointGroup  To Network  To IpAddress  Protocol  Port  Action
----  --------  ----------------  ----------  ---------     --------  ----  ------
```

Finally, associate the policy with a group (a group is an arbitrary collection of 
containers) and run some containers that belong to `db` group.

```
vagrant@tutorial-node1:~$ netctl group create contiv-net db -policy=db-policy
vagrant@tutorial-node1:~$ netctl group ls
Tenant   Group  Network     Policies
------   -----  -------     --------
default  db     contiv-net  db-policy

vagrant@tutorial-node1:~$ docker run -itd --name=contiv-db --net=db.contiv-net alpine /bin/sh
27eedc376ef43e5a5f3f4ede01635d447b1a0c313cca4c2a640ba4d5dea3573a
```

To verify this policy,  start the `netcat` utility to listen on an
arbitrary port within a container that belongs to `db` group. Then, from another container, 
scan a range of ports to confirm that only the one permitted by the `db` policy (in this
example, `port 8888`) is accessible on the db container.

```
vagrant@tutorial-node1:~$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' contiv-db
10.1.2.7

vagrant@tutorial-node1:~$ docker exec -it contiv-db /bin/sh
/ # nc -l 8888
<awaiting connection>
```

Switch over to the `tutorial-node2` window, run a web container, and verify the policy:

```
vagrant@tutorial-node2:~$ docker run -itd --name=contiv-web --net=contiv-net alpine /bin/sh
54108c756699071d527a567f9b5d266284aaf5299b888d75cd19ba1a40a1135a
vagrant@tutorial-node2:~$ docker exec -it contiv-web /bin/sh

/ # nc -nzvw 1 10.1.2.7 8890
nc: 10.1.2.7 (10.1.2.7:8890): Operation timed out
/ # nc -nzvw 1 10.1.2.7 8889
nc: 10.1.2.7 (10.1.2.7:8889): Operation timed out
/ # nc -nzvw 1 10.1.2.7 8888
/ #
```

Note that the last scan on port `8888` using `nc -nzvw 1 10.1.2.7 8888` returned
without any `Operation timed out` message. 

At this point you can add delete rules to the policy dynamically.

## Chapter 6: Running Containers in a Swarm Cluster

This chapter demostrated how to use the swarm scheduler by 
redirecting requests to an already provisioned
swarm cluster. 

To do so, set `DOCKER_HOST` as follows:

```
vagrant@tutorial-node1:~$ export DOCKER_HOST=tcp://192.168.2.10:2375
```

Look at the status of various hosts using `docker info`:

```
vagrant@tutorial-node1:~$ docker info
Containers: 16
Images: 3
Role: primary
Strategy: spread
Filters: health, port, dependency, affinity, constraint
Nodes: 2
 tutorial-node1: 192.168.2.10:2385
  └ Containers: 10
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 2.051 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.0.0-040000-generic, operatingsystem=Ubuntu 15.04, storagedriver=overlay
 tutorial-node2: 192.168.2.11:2385
  └ Containers: 6
  └ Reserved CPUs: 0 / 4
  └ Reserved Memory: 0 B / 2.051 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=4.0.0-040000-generic, operatingsystem=Ubuntu 15.04, storagedriver=overlay
CPUs: 8
Total Memory: 4.103 GiB
Name: tutorial-node1
No Proxy: 192.168.2.10,192.168.2.11,127.0.0.1,localhost,netmaster
```

The command displays details about the cluster, including number of nodes, 
number of containers in the cluster, available cpu and memory and more.

At this point any new containers scheduled dynamically across 
the cluster, which consists of the two nodes `tutorial-node1` and `tutorial-node2` in this tutorial.

Run two containers:

```
vagrant@tutorial-node1:~$ docker run -itd --name=contiv-cluster-c1 --net=contiv-net alpine /bin/sh
f8fa35c0aa0ecd692a31e3d5249f5c158bd18902926978265acb3b38a9ed1c0d
vagrant@tutorial-node1:~$ docker run -itd --name=contiv-cluster-c2 --net=contiv-net alpine /bin/sh
bfc750736007c307827ae5012755085ca6591f3ac3ac0b707d2befd00e5d1621
```

After you start the two containers, the scheduler schedules them using the
scheduling algorithm `bin-packing` or `spread` If the two containers are not placed on 
different nodes, start more containers until the some nodes appear on both containers.

To see which containers get scheduled on which node, use the `docker ps` command:

```
vagrant@tutorial-node1:~$ docker ps
CONTAINER ID        IMAGE                          COMMAND             CREATED             STATUS                  PORTS                         NAMES
bfc750736007        alpine                         "/bin/sh"           5 seconds ago       Up Less than a second                                 tutorial-node2/contiv-cluster-c2
f8fa35c0aa0e        alpine                         "/bin/sh"           22 seconds ago      Up 16 seconds                                         tutorial-node2/contiv-cluster-c1
54108c756699        alpine                         "/bin/sh"           14 minutes ago      Up 14 minutes                                         tutorial-node2/contiv-web
27eedc376ef4        alpine                         "/bin/sh"           25 minutes ago      Up 25 minutes                                         tutorial-node1/contiv-db
1c463ecad829        alpine                         "/bin/sh"           39 minutes ago      Up 39 minutes                                         tutorial-node2/contiv-vlan-c2
4bf58874c937        alpine                         "/bin/sh"           40 minutes ago      Up 40 minutes                                         tutorial-node1/contiv-vlan-c1
52bfcc02c362        alpine                         "/bin/sh"           About an hour ago   Up About an hour        192.168.2.10:9099->9099/tcp   tutorial-node1/contiv-exposed
0fd07b44d042        alpine                         "/bin/sh"           About an hour ago   Up About an hour                                      tutorial-node2/contiv-blue-c3
521abe19d6b5        alpine                         "/bin/sh"           About an hour ago   Up About an hour                                      tutorial-node2/contiv-blue-c2
6c7d8c0b14ec        alpine                         "/bin/sh"           2 hours ago         Up 2 hours                                            tutorial-node1/contiv-blue-c1
17afcd58b8fc        skynetservices/skydns:latest   "/skydns"           2 hours ago         Up 2 hours              53/tcp, 53/udp                tutorial-node1/bluedns
26b9f22b9790        alpine                         "/bin/sh"           2 hours ago         Up 2 hours                                            tutorial-node2/contiv-c2
46e619b0b418        alpine                         "/bin/sh"           2 hours ago         Up 2 hours                                            tutorial-node1/contiv-c1
fb822eda9916        alpine                         "/bin/sh"           2 hours ago         Up 2 hours                                            tutorial-node1/overlay-c2
0ab717006962        alpine                         "/bin/sh"           2 hours ago         Up 2 hours                                            tutorial-node1/overlay-c1
2cf083c0a4de        alpine                         "/bin/sh"           2 hours ago         Up 2 hours                                            tutorial-node1/vanilla-c
ab353464b4e2        skynetservices/skydns:latest   "/skydns"           2 hours ago         Up 2 hours              53/tcp, 53/udp                tutorial-node1/defaultdns
```

Finally, check the inter-container connectivity and external 
connectivity for the containers scheduled across multiple hosts:

```
vagrant@tutorial-node1:~$ docker exec -it contiv-cluster-c1 /bin/sh
/ # 
/ # 
/ # 
/ # ping contiv-cluster-c2
PING contiv-cluster-c2 (10.1.2.7): 56 data bytes
64 bytes from 10.1.2.7: seq=0 ttl=64 time=8.440 ms
64 bytes from 10.1.2.7: seq=1 ttl=64 time=1.479 ms
^C
--- contiv-cluster-c2 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 1.479/4.959/8.440 ms
/ # ping contiv.com
PING contiv.com (216.239.36.21): 56 data bytes
64 bytes from 216.239.36.21: seq=0 ttl=61 time=43.537 ms
64 bytes from 216.239.36.21: seq=1 ttl=61 time=38.867 ms
^C
--- contiv.com ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 38.867/41.202/43.537 ms
```

## Clean Up
To clean up after doing all the exercises, use Vagrant to
tear down the tutorial VM environment:

```
$ vagrant destroy -f
==> tutorial-node2: Forcing shutdown of VM...
==> tutorial-node2: Destroying VM and associated drives...
==> tutorial-node1: Forcing shutdown of VM...
==> tutorial-node1: Destroying VM and associated drives...
```

## References
1. [CNI Specification](https://github.com/containernetworking/cni/blob/master/SPEC.md)
2. [CNM Design](https://github.com/docker/libnetwork/blob/master/docs/design.md)
3. [Contiv User Guide](http://docs.contiv.io)
4. [Contiv Networking Code](https://github.com/contiv/netplugin)


## Improvements or Comments
Thank you for trying this tutorial.  The tutorial was developed by Contiv engineers, 
and we welcome your feedback.  Please file a GitHub issue to report errors or suggest
improvements, or, if you prefer, please feel free to send a pull request to the 
[website repository](https://github.com/contiv/contiv.github.io.git).
