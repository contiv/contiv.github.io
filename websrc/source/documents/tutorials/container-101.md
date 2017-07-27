---
layout: "documents"
page_title: "Container Networking Tutorial (Legacy Swarm)"
sidebar_current: "tutorials-container-101"
description: |-
  Container Networking Tutorial (Legacy Swarm)
---




## Containers Networking Tutorial with Contiv + Legacy Swarm

  - [Prerequisites](#prereqs)
  - [Setup](#setup)
  - [Chapter 1 - Introduction to Container Networking](#ch1)
  - [Chapter 2 - Multi-host networking](#ch2)
  - [Chapter 3 - Using multiple tenants with arbitrary IPs in the networks](#ch3)
  - [Chapter 4 - Connecting containers to external networks](#ch4)
  - [Chapter 5 - Docker Overlay multi-host networking](#ch5)
  - [Cleanup](#cleanup)

This tutorial will walk through container networking and concepts step by step in the Legacy Swarm environment. We will explore Contiv's networking features along with policies in the next tutorial.

### <a name="prereqs"></a> Prerequisites 
1. [Download Vagrant](https://www.vagrantup.com/downloads.html)
2. [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)
3. [Install Git client](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
4. [Install Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

**Note**:
If you are using a platform other than Mac, please install docker-engine for that platform.

Make virtualbox the default provider for vagrant

```
export VAGRANT_DEFAULT_PROVIDER=virtualbox
```

The steps below download a CentOS vagrant box. If you have a CentOS box available already, or you have access to the box file, add it to list of box images with the specific name centos/7, as follows:

```
vagrant box add --name centos/7 CentOS-7-x86_64-Vagrant-1703_01.VirtualBox.box
```
 
### <a name="setup"></a> Setup

#### Step 1: Get the Contiv installer code from Github.
```
$ git clone https://github.com/contiv/install.git
$ cd install
```

#### Step 2: Install Contiv + Legacy Swarm using Vagrant on the VMs created on VirtualBox

**Note**:
Please make sure that you are NOT connected to VPN here.

```
$ make demo-legacy-swarm
```
**Note**: Please do not try to work in both the Legacy Swarm and Kubernetes environments at the same time. This will not work.

This will create two VMs on VirtualBox. It will install Legacy Swarm and all the required services and software for Contiv using Ansible. This might take some time (usually approx 15-20 mins) depending upon your internet connection.

-- OR --
#### Step 2a: Create a Vagrant VM cluster

```
$ make cluster-legacy-swarm
```

This will create two VMs on VirtualBox. It will also create a cluster/.cfg_legacy-swarm.yaml config file that will be used in later steps. Setup the following two config vars.

```
$ cd cluster
$ export SSH_KEY=$(vagrant ssh-config legacy-swarm-master | grep IdentityFile | awk '{print $2}' | xargs)
$ export USER="vagrant"
```

#### Step 2b: Download Contiv release bundle

```
$ cd .. # go back to the install folder
$ curl -L -O https://github.com/contiv/install/releases/download/1.0.3/contiv-1.0.3.tgz
$ tar xf contiv-1.0.3.tgz
```

#### Step 2c: Install Contiv
```
$ cd contiv-1.0.3
$ ./install/ansible/install_swarm.sh -f ../cluster/.cfg_legacy-swarm.yaml -e ${SSH_KEY} -u ${USER} -i
$ cd ..
```

Make note of the final outcome of this process. This lists the URL for Legacy Swarm as well as the UI. There are instructions for setting up a default network as well.

```
Installation is complete
=========================================================

Please export DOCKER_HOST=tcp://192.168.2.50:2375 in your shell before proceeding
Contiv UI is available at https://192.168.2.50:10000
Please use the first run wizard or configure the setup as follows:
 Configure forwarding mode (optional, default is bridge).
 netctl global set --fwd-mode routing
 Configure ACI mode (optional)
 netctl global set --fabric-mode aci --vlan-range -
 Create a default network
 netctl net create -t default --subnet= default-net
 For example, netctl net create -t default --subnet=20.1.1.0/24 default-net

=========================================================
```

#### Step 3: Check vagrant VM nodes.

**Note**:
On Windows, you will need a ssh client to be installed like putty, cygwin etc.

This command will show you list of VMs which we have created. Make sure you are in the cluster folder.

```
$ vagrant status
Current machine states:

legacy-swarm-master       running (virtualbox)
legacy-swarm-worker0      running (virtualbox)

```
The above command shows the node information, version, etc.

#### Step 4: Hello world Docker Swarm.

As a part of this Contiv installation, we install Legacy Swarm for you. To verify the Legacy Swarm cluster, please execute the following commands on the Vagrant VMs.

```
$ vagrant ssh legacy-swarm-master
```
Now you will be logged into the Legacy Swarm master Vagrant VM. To run Docker without sudo, add user to docker group in the master and worker nodes.

```
[vagrant@legacy-swarm-master ~]$ sudo usermod -aG docker $USER
[vagrant@legacy-swarm-master ~]$ exit

$ vagrant ssh legacy-swarm-worker0
[vagrant@legacy-swarm-worker0 ~]$ sudo usermod -aG docker $USER
[vagrant@legacy-swarm-worker0 ~]$ exit
$ vagrant ssh legacy-swarm-master

```

Setup DOCKER_HOST variable based on the output of installation step above.

```
[vagrant@legacy-swarm-master ~]$ export DOCKER_HOST=tcp://192.168.2.50:2375
[vagrant@legacy-swarm-master ~]$ docker info
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
 legacy-swarm-master: 192.168.2.50:2385
  └ ID: EXNZ:MJZH:U2R4:YKGA:Z46L:EVHK:5SCG:UJWA:ZBJ2:UJ6F:SODY:OOQZ
  └ Status: Healthy
  └ Containers: 4 (4 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 513.1 MiB
  └ Labels: kernelversion=3.10.0-514.10.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-06-14T04:32:44Z
  └ ServerVersion: 1.12.6
 legacy-swarm-worker0: 192.168.2.51:2385
  └ ID: 5KLY:AYCB:OZBI:NW5P:DNNN:V6VE:EHBJ:AJ2F:JZT4:HNJF:NE3B:7X2W
  └ Status: Healthy
  └ Containers: 2 (2 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 513.1 MiB
  └ Labels: kernelversion=3.10.0-514.10.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-06-14T04:32:19Z
  └ ServerVersion: 1.12.6
Plugins:
 Volume:
 Network:
Swarm:
 NodeID:
 Is Manager: false
 Node Address:
Security Options:
Kernel Version: 3.10.0-514.10.2.el7.x86_64
Operating System: linux
Architecture: amd64
CPUs: 2
Total Memory: 1.002 GiB
Name: legacy-swarm-master
Docker Root Dir:
Debug Mode (client): false
Debug Mode (server): false
WARNING: No kernel memory limit support


```

You can see a two node Legacy Swarm cluster running successfully.
Scheduler schedules these containers using the scheduling algorithm `bin-packing` or `spread`. If they are not placed on different nodes, feel free to start more containers to see the distribution.

#### Step 5: Check contiv and related services.

`etcdctl` is a control utility to manipulate etcd, state store used by kubernetes/docker/contiv

To check etcd cluster health

```
[vagrant@legacy-swarm-master ~]$ etcdctl cluster-health
member a7a2e9cf2f6b1520 is healthy: got healthy result from http://192.168.2.50:2379
cluster is healthy
```

To check netplugin and netmaster is running successfully.

```
[vagrant@legacy-swarm-master ~]$ sudo service netmaster status
Redirecting to /bin/systemctl status  netmaster.service
● netmaster.service - Netmaster
   Loaded: loaded (/etc/systemd/system/netmaster.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-06-14 04:28:37 UTC; 5min ago
 Main PID: 21308 (netmaster)
   CGroup: /system.slice/netmaster.service
           └─21308 /usr/bin/netmaster --cluster-mode docker -cluster-store etcd:/...

Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:02.49815...
Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: "
Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:02.50289...
Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:02.61681...
Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:02.61939...
Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:02.62245...
Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:02.91190...
Jun 14 04:30:02 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:02.91317...
Jun 14 04:30:05 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:05.20989...
Jun 14 04:30:05 legacy-swarm-master netmaster[21308]: time="Jun 14 04:30:05.21218...
Hint: Some lines were ellipsized, use -l to show in full.

[vagrant@legacy-swarm-master ~]$ sudo service netplugin status
Redirecting to /bin/systemctl status  netplugin.service
● netplugin.service - Netplugin
   Loaded: loaded (/etc/systemd/system/netplugin.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-06-14 04:28:28 UTC; 7min ago
 Main PID: 20584 (netplugin)
   CGroup: /system.slice/netplugin.service
           └─20584 /usr/bin/netplugin -plugin-mode docker -vlan-if eth2 -vtep-ip ...

Jun 14 04:30:02 legacy-swarm-master netplugin[20584]: time="Jun 14 04:30:02.44705...
Jun 14 04:30:02 legacy-swarm-master netplugin[20584]: time="Jun 14 04:30:02.44708...
Jun 14 04:30:02 legacy-swarm-master netplugin[20584]: time="Jun 14 04:30:02.44709...
Jun 14 04:30:02 legacy-swarm-master netplugin[20584]: time="Jun 14 04:30:02.44710...
Jun 14 04:30:02 legacy-swarm-master netplugin[20584]: time="Jun 14 04:30:02.75298...
Jun 14 04:34:37 legacy-swarm-master netplugin[20584]: time="Jun 14 04:34:37.14348...
Jun 14 04:35:22 legacy-swarm-master netplugin[20584]: time="Jun 14 04:35:22.13884...
Jun 14 04:35:22 legacy-swarm-master netplugin[20584]: time="Jun 14 04:35:22.14845...
Jun 14 04:36:07 legacy-swarm-master netplugin[20584]: time="Jun 14 04:36:07.11897...
Jun 14 04:36:07 legacy-swarm-master netplugin[20584]: time="Jun 14 04:36:07.12920...
Hint: Some lines were ellipsized, use -l to show in full.

```

`netctl` is a utility to create, update, read and modify contiv objects. It is a CLI wrapper
on top of REST interface.

```
[vagrant@legacy-swarm-master ~]$ netctl version
Client Version:
Version: 1.0.3
GitCommit: c61eb64
BuildTime: 06-08-2017.01-26-14.UTC

Server Version:
Version: 1.0.3
GitCommit: c61eb64
BuildTime: 06-08-2017.01-26-14.UTC
```


```
[vagrant@legacy-swarm-master ~]$ ifconfig docker0
docker0: flags=4099  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        ether 02:42:bf:4d:9d:ab  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[vagrant@legacy-swarm-master ~]$ ifconfig eth1
eth1: flags=4163  mtu 1500
        inet 192.168.2.50  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::a00:27ff:fe3f:db94  prefixlen 64  scopeid 0x20
        ether 08:00:27:3f:db:94  txqueuelen 1000  (Ethernet)
        RX packets 18379  bytes 9566674 (9.1 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 10321  bytes 2306239 (2.1 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[vagrant@legacy-swarm-master ~]$ ifconfig eth0
eth0: flags=4163  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::5054:ff:fe88:15b6  prefixlen 64  scopeid 0x20
        ether 52:54:00:88:15:b6  txqueuelen 1000  (Ethernet)
        RX packets 129583  bytes 124051779 (118.3 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 44605  bytes 2596926 (2.4 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

In the above output, you'll see the following interfaces:  
- `docker0` interface corresponds to the linux bridge and its associated
subnet `172.17.0.1/16`. This is created by docker daemon automatically, and
is the default network containers would belong to when an override network
is not specified  
- `eth0` in this VM is the management interface, on which we ssh into the VM  
- `eth1` in this VM is the interface that connects to external network (if needed)  
- `eth2` in this VM is the interface that carries vxlan and control (e.g. etcd) traffic  


### <a name="ch1"></a> Chapter 1: Introduction to Container Networking

There are two main container networking models discussed within the community.

#### Docker libnetwork - Container Network Model (CNM)

CNM (Container Network Model) is Docker's libnetwork network model for containers  
- An endpoint is a container's interface into a network  
- A network is collection of arbitrary endpoints
- A container can belong to multiple endpoints (and therefore multiple networks)  
- CNM allows for co-existence of multiple drivers, with a network managed by one driver  
- Provides Driver APIs for IPAM and Endpoint creation/deletion
- IPAM Driver APIs: Create/Delete Pool, Allocate/Free IP Address  
- Network Driver APIs: Network Create/Delete, Endpoint Create/Delete/Join/Leave  
- Used by docker engine, docker swarm, and docker compose; and other schedulers
that schedule regular docker containers e.g. Nomad or Mesos docker containerizer

#### CoreOS CNI - Container Network Interface (CNI)
CNI (Container Network Interface) CoreOS's network model for containers  
- Allows container id (uuid) specification for the network interface you create  
- Provides Container Create/Delete events  
- Provides access to network namespace to the driver to plumb networking  
- No separate IPAM Driver: Container Create returns the IPAM information along with other data
- Used by Kubernetes and thus supported by various Kubernetes network plugins, including Contiv  

Using Contiv with CNI/Kubernetes can be found [here](https://github.com/contiv/netplugin/tree/master/mgmtfn/k8splugin).
The rest of the tutorial walks through the docker examples, which implements CNM APIs.

#### Basic container networking

Let's examine the networking a container gets upon vanilla run.

```
[vagrant@legacy-swarm-master ~]$ docker network ls
NETWORK ID          NAME                          DRIVER              SCOPE
205d0b951c9b        legacy-swarm-master/bridge    bridge              local
8c79cc020852        legacy-swarm-master/host      host                local
92282e1a7aa0        legacy-swarm-master/none      null                local
27bdd6e2aacf        legacy-swarm-worker0/bridge   bridge              local
ebd623056f92        legacy-swarm-worker0/host     host                local
d4f9c8886927        legacy-swarm-worker0/none     null                local
```
```
[vagrant@legacy-swarm-master ~]$ docker run -itd --name=vanilla-c alpine /bin/sh
abe3cae574fb7b07fa228b88b4a0ff338029b9d8d7b5f77ea9c0802dd6162154

[vagrant@legacy-swarm-master ~]$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS               NAMES
abe3cae574fb        alpine                       "/bin/sh"                About a minute ago   Up About a minute                       legacy-swarm-worker0/vanilla-c
08c5621da092        contiv/auth_proxy:1.0.3      "./auth_proxy --tls-k"   12 minutes ago       Up 12 minutes                           legacy-swarm-master/auth-proxy
19eeadd6015d        quay.io/coreos/etcd:v2.3.8   "/etcd"                  16 minutes ago       Up 16 minutes                           legacy-swarm-worker0/etcd
1477be6b938f        quay.io/coreos/etcd:v2.3.8   "/etcd"                  17 minutes ago       Up 17 minutes                           legacy-swarm-master/etcd
```

**Note**:
This container got scheduled by Legacy Swarm on legacy-swarm-worker0 node, as seen in the NAMES column above. The following ifconfig has to be run on legacy-swarm-worker0 node only if the container is scheduled on legacy-swarm-worker0.

Switch to `legacy-swarm-worker0`

```
[vagrant@legacy-swarm-master ~]$ exit

$ vagrant ssh legacy-swarm-worker0

[vagrant@legacy-swarm-worker0 ~]$ ifconfig

[vagrant@legacy-swarm-worker0 ~]$ exit

$ vagrant ssh legacy-swarm-master

$ export DOCKER_HOST=tcp://192.168.2.50:2375

```

In the `ifconfig` output, you will see that it would have created a veth `virtual ethernet interface` that could look like `veth......` towards the end. More importantly it is allocated an IP address from default docker bridge `docker0`, likely `172.17.0.2` in this setup, and can be examined using

```
[vagrant@legacy-swarm-master ~]$ docker network inspect legacy-swarm-worker0/bridge
[
    {
        "Name": "bridge",
        "Id": "27bdd6e2aacfc9981de8ae8f2ef02f57933d4dd6913f0c115e0cd7cc1b7a16eb",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "abe3cae574fb7b07fa228b88b4a0ff338029b9d8d7b5f77ea9c0802dd6162154": {
                "Name": "vanilla-c",
                "EndpointID": "bdb0f1eb43703cc8e15bca7c47612f74ff2a80a28368b37596f56a79e9b2f0c8",
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
        },
        "Labels": {}
    }
]

[vagrant@legacy-swarm-master ~]$ docker inspect --format '{{.NetworkSettings.IPAddress}}' vanilla-c
172.17.0.2

```

The other pair of veth interface is put into the container with the name `eth0`.

```
[vagrant@legacy-swarm-master ~]$ docker exec -it vanilla-c /bin/sh
/ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:02
          inet addr:172.17.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)
/ # exit
```

All traffic to/from this container is Port-NATed to the host's IP (on eth0).
The Port NATing on the host is done using iptables, which can be seen as a
MASQUERADE rule for outbound traffic for `172.17.0.0/16`

```
[vagrant@legacy-swarm-master ~]$ sudo iptables -t nat -L -n
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
CONTIV-NODEPORT  all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL
...
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
MASQUERADE  all  --  172.19.0.0/16        0.0.0.0/0

Chain CONTIV-NODEPORT (1 references)
target     prot opt source               destination
...
```

### <a name="ch2"></a> Chapter 2: Multi-host networking

There are many solutions like Contiv such as Calico, Weave, OpenShift, OpenContrail, Nuage, VMWare, Docker, Kubernetes, and OpenStack that provide solutions to multi-host container networking. 

In this section, let's examine Contiv and Docker overlay solutions.

#### Multi-host networking with Contiv
Let's use the same example as above to spin up two containers on the two different hosts.

#### 1. Create a multi-host network

```
[vagrant@legacy-swarm-master ~]$ netctl net create --subnet=10.1.2.0/24 contiv-net
Creating network default:contiv-net
```
```
[vagrant@legacy-swarm-master ~]$ netctl net ls
Tenant   Network     Nw Type  Encap type  Packet tag  Subnet       Gateway  IPv6Subnet  IPv6Gateway  Cfgd Tag
------   -------     -------  ----------  ----------  -------      ------   ----------  -----------  ---------
default  contiv-net  data     vxlan       0           10.1.2.0/24
```
```
[vagrant@legacy-swarm-master ~]$ docker network ls
NETWORK ID          NAME                          DRIVER              SCOPE
72d7371e90b5        contiv-net                    netplugin           global
205d0b951c9b        legacy-swarm-master/bridge    bridge              local
8c79cc020852        legacy-swarm-master/host      host                local
92282e1a7aa0        legacy-swarm-master/none      null                local
27bdd6e2aacf        legacy-swarm-worker0/bridge   bridge              local
ebd623056f92        legacy-swarm-worker0/host     host                local
d4f9c8886927        legacy-swarm-worker0/none     null                local

[vagrant@legacy-swarm-master ~]$ docker network inspect contiv-net
[
    {
        "Name": "contiv-net",
        "Id": "72d7371e90b55f808ffeef7ddfec586f15a6c80e63d002e9eed110b0faab773d",
        "Scope": "global",
        "Driver": "netplugin",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "netplugin",
            "Options": {
                "network": "contiv-net",
                "tenant": "default"
            },
            "Config": [
                {
                    "Subnet": "10.1.2.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {},
        "Options": {
            "encap": "vxlan",
            "pkt-tag": "1",
            "tenant": "default"
        },
        "Labels": {}
    }
]
```

We can now spin a couple of containers belonging to the `contiv-net` network. Specifying a node constraint forces the container to start on a different host.

```
[vagrant@legacy-swarm-master ~]$ docker run -itd --name=contiv-c1 --net=contiv-net -e constraint:node==legacy-swarm-master alpine /bin/sh
021b3e7e21a8284a6d46657ef6f3477eafc594ef0c8080351af0f3d2e52dbd5e
```
```
[vagrant@legacy-swarm-master ~]$ docker run -itd --name=contiv-c2 --net=contiv-net -e constraint:node==legacy-swarm-worker0 alpine /bin/sh
93f39b9cf9e27f3b1b3d3d4f33232843ca84547eb8a83d2325e95216a72b7173
```
You can see which containers have been created.

```
[vagrant@legacy-swarm-master ~]$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS               NAMES
93f39b9cf9e2        alpine                       "/bin/sh"                27 seconds ago      Up 26 seconds                           legacy-swarm-worker0/contiv-c2
021b3e7e21a8        alpine                       "/bin/sh"                45 seconds ago      Up 42 seconds                           legacy-swarm-master/contiv-c1
abe3cae574fb        alpine                       "/bin/sh"                16 minutes ago      Up 16 minutes                           legacy-swarm-worker0/vanilla-c
08c5621da092        contiv/auth_proxy:1.0.3      "./auth_proxy --tls-k"   28 minutes ago      Up 28 minutes                           legacy-swarm-master/auth-proxy
19eeadd6015d        quay.io/coreos/etcd:v2.3.8   "/etcd"                  31 minutes ago      Up 31 minutes                           legacy-swarm-worker0/etcd
1477be6b938f        quay.io/coreos/etcd:v2.3.8   "/etcd"                  32 minutes ago      Up 32 minutes                           legacy-swarm-master/etcd
```
Now try to ping between containers.

```
[vagrant@legacy-swarm-master ~]$ docker exec -it contiv-c2 /bin/sh

/ # ping -c 3 contiv-c1
PING contiv-c1 (10.1.2.1): 56 data bytes
64 bytes from 10.1.2.1: seq=0 ttl=64 time=1.217 ms
64 bytes from 10.1.2.1: seq=1 ttl=64 time=0.878 ms
64 bytes from 10.1.2.1: seq=2 ttl=64 time=0.954 ms

--- contiv-c1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.878/1.016/1.217 ms

/ # exit
```

You can see that during the ping, the built-in DNS resolves the name `contiv-c1` to the IP address of the `contiv-c1` container and uses the vxlan overlay to communicate with the other container.

#### Docker Overlay multi-host networking

Docker engine has a built in overlay driver that can be use to connect
containers across multiple nodes. However since vxlan port used by `contiv`
driver is same as that of `overlay` driver from Docker, we will use
Docker's overlay multi-host networking towards the end after we experiment
with `contiv` because then we can terminate the contiv driver and
let Docker overlay driver use the vxlan port bindings. More about it in
later chapter.

### <a name="ch3"></a> Chapter 3: Using multiple tenants with arbitrary IPs in the networks

First, let's create a new tenant space.

```
[vagrant@legacy-swarm-master ~]$ export DOCKER_HOST="tcp://192.168.2.50:2375"
[vagrant@legacy-swarm-master ~]$ netctl tenant create blue
Creating tenant: blue
```
```
[vagrant@legacy-swarm-master ~]$ netctl tenant ls
Name
------
default
blue
```

After the tenant is created, we can create network within tenant `blue`.
Here we can choose the same subnet and network name as we used earlier with default tenant, as namespaces
are isolated across tenants.

```
[vagrant@legacy-swarm-master ~]$ netctl net create -t blue --subnet=10.1.2.0/24 contiv-net
Creating network blue:contiv-net
```
```
[vagrant@legacy-swarm-master ~]$ netctl net ls -t blue
Tenant  Network     Nw Type  Encap type  Packet tag  Subnet       Gateway  IPv6Subnet  IPv6Gateway  Cfgd Tag
------  -------     -------  ----------  ----------  -------      ------   ----------  -----------  ---------
blue    contiv-net  data     vxlan       0           10.1.2.0/24
```

Next, we can run containers belonging to this tenant.

```
[vagrant@legacy-swarm-master ~]$ docker run -itd --name=contiv-blue-c1 --net="contiv-net/blue" alpine /bin/sh
ea49d3f17e5f51404221d199b0502973c0005a2c7baf1827e569cb135958d77e

[vagrant@legacy-swarm-master ~]$ docker run -itd --name=contiv-blue-c2 --net="contiv-net/blue" alpine /bin/sh
0a77b2ed472291423ccca4efdd14e8524eec5ae3c51c273b83f74b5eea961369

[vagrant@legacy-swarm-master ~]$ docker run -itd --name=contiv-blue-c3 --net="contiv-net/blue" alpine /bin/sh
40e249715badb157faa84890c2521528ce1068165482635c8644856830dacd73
```
```
[vagrant@legacy-swarm-master ~]$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS               NAMES
40e249715bad        alpine                       "/bin/sh"                17 seconds ago      Up 16 seconds                           legacy-swarm-worker0/contiv-blue-c3
0a77b2ed4722        alpine                       "/bin/sh"                44 seconds ago      Up 42 seconds                           legacy-swarm-master/contiv-blue-c2
ea49d3f17e5f        alpine                       "/bin/sh"                58 seconds ago      Up 56 seconds                           legacy-swarm-worker0/contiv-blue-c1
93f39b9cf9e2        alpine                       "/bin/sh"                6 minutes ago       Up 6 minutes                            legacy-swarm-worker0/contiv-c2
021b3e7e21a8        alpine                       "/bin/sh"                6 minutes ago       Up 6 minutes                            legacy-swarm-master/contiv-c1
abe3cae574fb        alpine                       "/bin/sh"                22 minutes ago      Up 22 minutes                           legacy-swarm-worker0/vanilla-c
08c5621da092        contiv/auth_proxy:1.0.3      "./auth_proxy --tls-k"   33 minutes ago      Up 33 minutes                           legacy-swarm-master/auth-proxy
19eeadd6015d        quay.io/coreos/etcd:v2.3.8   "/etcd"                  37 minutes ago      Up 37 minutes                           legacy-swarm-worker0/etcd
1477be6b938f        quay.io/coreos/etcd:v2.3.8   "/etcd"                  38 minutes ago      Up 38 minutes                           legacy-swarm-master/etcd

[vagrant@legacy-swarm-master ~]$ docker network inspect contiv-net/blue
[
    {
        "Name": "contiv-net/blue",
        "Id": "f0f2adcd10d59a8ee95d0cb6b8cda6d4b767e62dcfec788bc25d8d767453731a",
        "Scope": "global",
        "Driver": "netplugin",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "netplugin",
            "Options": {
                "network": "contiv-net",
                "tenant": "blue"
            },
            "Config": [
                {
                    "Subnet": "10.1.2.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "0a77b2ed472291423ccca4efdd14e8524eec5ae3c51c273b83f74b5eea961369": {
                "Name": "contiv-blue-c2",
                "EndpointID": "c29173b07d45f9433ee6f7e116049bacbe3f60273559e8c7327e29fb01462fd2",
                "MacAddress": "02:02:0a:01:02:02",
                "IPv4Address": "10.1.2.2/24",
                "IPv6Address": ""
            },
            "40e249715badb157faa84890c2521528ce1068165482635c8644856830dacd73": {
                "Name": "contiv-blue-c3",
                "EndpointID": "d306f5e7c43479d7041202857c17e47e5001933f2110e2bab68f24b3575650d7",
                "MacAddress": "02:02:0a:01:02:03",
                "IPv4Address": "10.1.2.3/24",
                "IPv6Address": ""
            },
            "ea49d3f17e5f51404221d199b0502973c0005a2c7baf1827e569cb135958d77e": {
                "Name": "contiv-blue-c1",
                "EndpointID": "e1a91a78eeb38331c8f717b7c4994a81f6764fd01f71161c0f1748ae425e95a1",
                "MacAddress": "02:02:0a:01:02:01",
                "IPv4Address": "10.1.2.1/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "encap": "vxlan",
            "pkt-tag": "2",
            "tenant": "blue"
        },
        "Labels": {}
    }
]
```
Now let's try to ping between these containers.

```
[vagrant@legacy-swarm-master ~]$ docker exec -it contiv-blue-c3 /bin/sh

/ # ping -c 3 contiv-blue-c1
PING contiv-blue-c1 (10.1.2.1): 56 data bytes
64 bytes from 10.1.2.1: seq=0 ttl=64 time=1.173 ms
64 bytes from 10.1.2.1: seq=1 ttl=64 time=0.087 ms
64 bytes from 10.1.2.1: seq=2 ttl=64 time=0.090 ms

--- contiv-blue-c1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.087/0.450/1.173 ms

/ # ping -c 3 contiv-blue-c2
PING contiv-blue-c2 (10.1.2.2): 56 data bytes
64 bytes from 10.1.2.2: seq=0 ttl=64 time=2.441 ms
64 bytes from 10.1.2.2: seq=1 ttl=64 time=0.936 ms
64 bytes from 10.1.2.2: seq=2 ttl=64 time=0.969 ms

--- contiv-blue-c2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.936/1.448/2.441 ms
/ # exit
```

### <a name="ch4"></a> Chapter 4: Connecting containers to external networks

In this chapter, we explore ways to connect containers to the external networks

#### 1. External Connectivity using Host NATing

Docker uses the linux bridge (docker_gwbridge) based PNAT to reach out and port mappings
for others to reach to the container

```
[vagrant@legacy-swarm-master ~]$ docker exec -it contiv-c1 /bin/sh

/ # ifconfig -a
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:02:01
          inet addr:10.1.2.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:201/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:33 errors:0 dropped:0 overruns:0 frame:0
          TX packets:25 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2906 (2.8 KiB)  TX bytes:2258 (2.2 KiB)

eth1      Link encap:Ethernet  HWaddr 02:42:AC:12:00:02
          inet addr:172.18.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe12:2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:24 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1896 (1.8 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


/ # ping -c 3 contiv.com
PING contiv.com (216.239.32.21): 56 data bytes
64 bytes from 216.239.32.21: seq=0 ttl=61 time=38.088 ms
64 bytes from 216.239.32.21: seq=1 ttl=61 time=57.052 ms
64 bytes from 216.239.32.21: seq=2 ttl=61 time=53.208 ms

--- contiv.com ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 38.088/49.449/57.052 ms

/ # exit
```

What you see is that container has two interfaces belonging to it:  
- eth0 is reachability into the `contiv-net`  
- eth1 is reachability for container to the external world and outside traffic to be able to reach the container `contiv-c1`. This also relies on the host's dns resolv.conf as a default way to resolve non container IP resolution.

Similarly outside traffic can be exposed on specific ports using the `-p` command. Before
we do that, let us confirm that port 9099 is not reachable from the master node. Let's first install some commands.

```
# Install nc utility
[vagrant@legacy-swarm-master ~]$ sudo yum -y install nc
< some yum install output >
Complete!

[vagrant@legacy-swarm-master ~]$ sudo yum -y install tcpdump
< some yum install output >
Complete!

[vagrant@legacy-swarm-master ~]$ nc -vw 1 localhost 9099
Ncat: Version 6.40 ( http://nmap.org/ncat )
Ncat: Connection refused.
```

Now we start a container that exposes tcp port 9099 out in the host.

```
[vagrant@legacy-swarm-master ~]$ docker run -itd -p 9099:9099 --name=contiv-exposed --net=contiv-net alpine /bin/sh
ca1afea11f572b292c6bf5da821ee515d45b8fc73b62c52d2095e2b92f88c44a
```

And if we re-run our `nc` utility, we'll see that 9099 is reachable.

```
[vagrant@legacy-swarm-master ~]$ nc -vw 1 localhost 9099
Ncat: Version 6.40 ( http://nmap.org/ncat )
Ncat: Connected to 127.0.0.1:9099.
^C
```

This happens because docker as soon as a port is exposed, a NAT rule is installed for
the port to allow rest of the network to access the container on the specified/exposed
port. The nat rules on the host can be seen by:

```
[vagrant@legacy-swarm-master ~]$ sudo iptables -t nat -L -n
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
CONTIV-NODEPORT  all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL
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
MASQUERADE  all  --  172.19.0.0/16        0.0.0.0/0
MASQUERADE  tcp  --  172.18.0.4           172.18.0.4           tcp dpt:9099

Chain CONTIV-NODEPORT (1 references)
target     prot opt source               destination

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9099 to:172.18.0.4:9099
```

#### 2. Natively connecting to the external networks

Remote drivers, like Contiv, can provide an easy way to connect to external
layer2 or layer3 networks using BGP or standard L2 access into the network.

Preferably using an BGP hand-off to the leaf/TOR, this can be done as in 
[http://contiv.github.io/documents/networking/bgp.html], which describes how
can you use BGP with Contiv to provide native container connectivity and 
reachability to rest of the network. However for this tutorial, since we don't
have a real or simulated BGP router, we'll use some very simple native L2
connectivity to describe the power of native connectivity. This is done 
using vlan network, for example

```
[vagrant@legacy-swarm-master ~]$ netctl net create -p 112 -e vlan -s 10.1.3.0/24 contiv-vlan
Creating network default:contiv-vlan

[vagrant@legacy-swarm-master ~]$ netctl net ls
Tenant   Network      Nw Type  Encap type  Packet tag  Subnet       Gateway  IPv6Subnet  IPv6Gateway  Cfgd Tag
------   -------      -------  ----------  ----------  -------      ------   ----------  -----------  ---------
default  contiv-vlan  data     vlan        112         10.1.3.0/24
default  contiv-net   data     vxlan       0           10.1.2.0/24

```

The allocated vlan can be used to connect any workload in vlan 112 in the network infrastructure.
The interface that connects to the outside network needs to be specified during netplugin
start, for this VM configuration it is set as `eth2`

Let's run some containers to belong to this network, one on each node. First one on 
`legacy-swarm-master`

```
[vagrant@legacy-swarm-master ~]$ docker run -itd --name=contiv-vlan-c1 --net=contiv-vlan -e constraint:node==legacy-swarm-master alpine /bin/sh
39c1c3774f863a4d7f086ce7b7e512329c86c5962f97601654486231ddaa9e4e
```

And another one on `legacy-swarm-worker0`

```
[vagrant@legacy-swarm-master ~]$ docker run -itd --name=contiv-vlan-c2 --net=contiv-vlan -e constraint:node==legacy-swarm-worker0 alpine /bin/sh
5644ad0d47576b48655bf406ea33da54caae31d7cf004f7ab9a5ca1512feb24c

Open a new terminal and connect to the worker node legacy-swarm-worker0.

$ vagrant ssh legacy-swarm-worker0

[vagrant@legacy-swarm-worker0 ~]$ docker exec -it contiv-vlan-c2 /bin/sh
/ # ping contiv-vlan-c1
PING contiv-vlan-c1 (10.1.3.1): 56 data bytes
64 bytes from 10.1.3.1: seq=0 ttl=64 time=1.163 ms
64 bytes from 10.1.3.1: seq=1 ttl=64 time=0.085 ms
64 bytes from 10.1.3.1: seq=2 ttl=64 time=0.094 ms
...
```

While this is going on `legacy-swarm-worker0`, let's run tcpdump on eth2 on `legacy-swarm-master`
and confirm how rx/tx packets look on it:

```
[vagrant@legacy-swarm-master ~]$ sudo tcpdump -e -i eth2 icmp
tcpdump: WARNING: eth2: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), capture size 65535 bytes
05:26:32.768233 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:01 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.1: ICMP echo request, id 2816, seq 0, length 64
05:26:33.768908 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:01 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.1: ICMP echo request, id 2816, seq 1, length 64
05:26:34.769469 02:02:0a:01:03:02 (oui Unknown) > 02:02:0a:01:03:01 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.2 > 10.1.3.1: ICMP echo request, id 2816, seq 2, length 64
^C
3 packets captured
3 packets received by filter
0 packets dropped by kernel
```

Note: The vlan shown in tcpdump is same (i.e. `112`) as what we configured in the VLAN. After verifying this, feel free to stop the ping that is still running on 
`contiv-vlan-c2` container.


### <a name="ch5"></a> Chapter 5: Docker Overlay multi-host networking

As we learned earlier that using the vxlan port conflict can prevent us from using
Docker `overlay` network. For us to experiment with this, we'd go ahead
and terminate `contiv` driver first on both nodes: `legacy-swarm-master` and
`legacy-swarm-worker0`:

```
[vagrant@legacy-swarm-master ~]$ sudo service netplugin stop
Redirecting to /bin/systemctl stop  netplugin.service

[vagrant@legacy-swarm-worker0 ~]$ sudo service netplugin stop
Redirecting to /bin/systemctl stop  netplugin.service
```

To try out overlay driver, we switch to `legacy-swarm-master` and create an overlay network first.

```
[vagrant@legacy-swarm-master ~]$ docker network create -d=overlay --subnet=30.1.1.0/24 overlay-net
db97986a0e61bb09d41918489b991ff786d8391b1b452edc28f8374cf870823b

[vagrant@legacy-swarm-master ~]$ docker network inspect overlay-net
[
    {
        "Name": "overlay-net",
        "Id": "db97986a0e61bb09d41918489b991ff786d8391b1b452edc28f8374cf870823b",
        "Scope": "global",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "30.1.1.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

Now, we can create few containers that belongs to `overlay-net`, which can get scheduled
on any of the available nodes by the scheduler. Note that we still have DOCKER_HOST set to point
to the swarm cluster.

```
[vagrant@legacy-swarm-master ~]$ docker run -itd --name=overlay-c1 --net=overlay-net alpine /bin/sh
115b8cec9a3e7148b91bbb17b51e150b387d5d06f783e558b7bb58a2110a003c

[vagrant@legacy-swarm-master ~]$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' overlay-c1
30.1.1.2

[vagrant@legacy-swarm-master ~]$ docker run -itd --name=overlay-c2 --net=overlay-net alpine /bin/sh
68e4daada1082009472ad5f61c32604ebcf0a2079c02bc714c056e25b967037c

[vagrant@clegacy-swarm-master ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS               NAMES
825a80fb54c4        alpine                           "/bin/sh"                38 seconds ago       Up 37 seconds                           contiv-node4/overlay-c2
82079ffd25d4        alpine                           "/bin/sh"                About a minute ago   Up About a minute                       contiv-node4/overlay-c1
cf720d2e5409        contiv/auth_proxy:1.0.0-beta.5   "./auth_proxy --tls-k"   3 hours ago          Up 3 hours                              contiv-node3/auth-proxy
2d450e95bb3b        quay.io/coreos/etcd:v2.3.8       "/etcd"                  4 hours ago          Up 4 hours                              contiv-node4/etcd
78c09b21c1fa        quay.io/coreos/etcd:v2.3.8       "/etcd"                  4 hours ago          Up 4 hours                              contiv-node3/etcd

[vagrant@legacy-swarm-master ~]$ docker exec -it overlay-c2 /bin/sh
/ # ping overlay-c1
PING overlay-c1 (30.1.1.2): 56 data bytes
64 bytes from 30.1.1.2: seq=0 ttl=64 time=0.105 ms
64 bytes from 30.1.1.2: seq=1 ttl=64 time=0.089 ms
64 bytes from 30.1.1.2: seq=2 ttl=64 time=0.109 ms
^C
--- overlay-c1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.075/0.087/0.096 ms

/ # exit
```

Very similar to contiv-networking, built in dns resolves the name `overlay-c1`
to the IP address of `overlay-c1` container and be able to reach another container
across using a vxlan overlay.

### <a name="cleanup"></a> Cleanup:

To cleanup the setup, after doing all the experiments, exit the VM and destroy the VMs:

```
[vagrant@legacy-swarm-master ~]$ exit
logout
Connection to 127.0.0.1 closed.
```
```
$ cd .. # go back to install directory
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
```
```
$ make vagrant-clean
```

### References
1. [CNI Specification](https://github.com/containernetworking/cni/blob/master/SPEC.md)
2. [CNM Design](https://github.com/docker/libnetwork/blob/master/docs/design.md)
3. [Contiv User Guide](http://docs.contiv.io)
4. [Contiv Networking Code](https://github.com/contiv/netplugin)


### Improvements or Comments
This tutorial was developed by Contiv engineers. Thank you for trying out this tutorial.
Please file a GitHub issue if you see an issue with the tutorial, or if you prefer
improving some text, feel free to send a pull request.
