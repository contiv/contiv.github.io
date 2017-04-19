---
layout: "documents"
page_title: "Container Networking Tutorial"
sidebar_current: "tutorials-container-101"
description: |-
  Container Networking Tutorial
---


## Containers Networking Tutorial with Contiv
Walks through container networking and concepts step by step. We will explore Contiv's networking features along with policies, in next tutorial.

### Prerequisites 
1. [Download Vagrant](https://www.vagrantup.com/downloads.html)
2. [Download Virtualbox](https://www.virtualbox.org/wiki/Downloads)
3. [Install git client](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
4. [Install docker for mac](https://docs.docker.com/docker-for-mac/install/)

**Note**:
- If you are using platform other than Mac, please install docker-engine, for that platform.

Make virtualbox the default provider for vagrant

```
export VAGRANT_DEFAULT_PROVIDER=virtualbox
```

Cluster build steps below download a centos vagrant box. If you have a centos box available already, or you have access to the box file, add it to list of box images with specific name centos/7, as follows:

```
vagrant box add --name centos/7 CentOS-7-x86_64-Vagrant-1703_01.VirtualBox.box
```
 
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
$ make demo-swarm
```
This will create two VMs on VirtualBox. Using ansible, all the required services and software for contiv, will get installed at this step.
This might take some time (usually approx 15-20 mins) depending upon your internet connection.

-- or --
#### Step 2a: Create a vagrant VM cluster

```
$ make cluster
```

This will create two VMs on VirtualBox. It will also create a .cfg.yml config file that will be used in later steps. Also setup the following two config vars

```
$ cd cluster
$ export SSH_KEY=$(vagrant ssh-config contiv-node3 | grep IdentityFile | awk '{print $2}' | xargs)
$ export USER="vagrant"
```

#### Step 2b: Download contiv release bundle

```
$ wget https://github.com/contiv/install/releases/download/1.0.0/contiv-1.0.0.tgz
$ tar -zxvf contiv-1.0.0.tgz
```

#### Step 2c: Use config file to install contiv
```
$ cd contiv-1.0.0
$ ./install/ansible/install_swarm.sh -f ../.cfg.yml -e ${SSH_KEY} -u ${USER} -i
$ cd ..
```

Make note of final outcome of this process. This lists the URL for docker swarm as well as for UI.

```
Installation is complete
=========================================================

Please export DOCKER_HOST=tcp://192.168.2.52:2375 in your shell before proceeding
Contiv UI is available at https://192.168.2.52:10000
Please use the first run wizard or configure the setup as follows:
 Configure forwarding mode (optional, default is bridge).
 netctl global set --fwd-mode routing
 Configure ACI mode (optional)
 netctl global set --fabric-mode aci --vlan-range <start>-<end>
 Create a default network
 netctl net create -t default --subnet=<CIDR> default-net
 For example, netctl net create -t default --subnet=20.1.1.0/24 default-net

=========================================================
```

#### Step 3: Check vagrant VM nodes.

**Note**:
- On Windows, you will need a ssh client to be installed like putty, cygwin etc.

```
This command will show you list of VMs which we have created. 
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
$ vagrant ssh contiv-node3
```
To run docker without sudo, add user to docker group, quit and ssh again.

```
[vagrant@contiv-node3 ~]$ sudo usermod -aG docker $USER
[vagrant@contiv-node3 ~]$ exit
$ vagrant ssh contiv-node3
```

Now you will be logged into one of the Vagrant VM. Setup DOCKER_HOST variable based on the output of installation step above.

```
[vagrant@contiv-node3 ~]$ export DOCKER_HOST=tcp://192.168.2.52:2375
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
  └ ID: FK7R:SF5N:KRVW:VSYH:VVR5:6BSO:ZUBB:3BPA:U6VM:YE4D:4EQK:HLCW
  └ Status: Healthy
  └ Containers: 4 (4 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.018 GiB
  └ Labels: kernelversion=3.10.0-514.6.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-03-30T04:04:54Z
  └ ServerVersion: 1.12.6
 contiv-node4: 192.168.2.53:2385
  └ ID: NVO2:Y6PR:M7F2:4EIL:PDKF:ZC7Z:A2BP:HUIC:K2IJ:IX3F:2JWB:TYML
  └ Status: Healthy
  └ Containers: 2 (2 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.018 GiB
  └ Labels: kernelversion=3.10.0-514.6.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-03-30T04:04:09Z
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
   Active: active (running) since Thu 2017-03-30 04:00:49 UTC; 8min ago
 Main PID: 19412 (netmaster)
   CGroup: /system.slice/netmaster.service
           └─19412 /usr/bin/netmaster --cluster-mode docker -cluster-store etcd://192.168.2.52:2379

Mar 30 04:02:02 contiv-node3 netmaster[19412]: "
Mar 30 04:02:02 contiv-node3 netmaster[19412]: time="Mar 30 04:02:02.580108038" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9002}"
Mar 30 04:02:02 contiv-node3 netmaster[19412]: time="Mar 30 04:02:02.690562420" level=info msg="Connecting to RPC server: 192.168.2.53:9003"
Mar 30 04:02:02 contiv-node3 netmaster[19412]: time="Mar 30 04:02:02.692078723" level=info msg="Connected to RPC server: 192.168.2.53:9003"
Mar 30 04:02:02 contiv-node3 netmaster[19412]: time="Mar 30 04:02:02.694238710" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9003}"
Mar 30 04:02:03 contiv-node3 netmaster[19412]: time="Mar 30 04:02:03.136923289" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9003}"
Mar 30 04:02:03 contiv-node3 netmaster[19412]: time="Mar 30 04:02:03.138000567" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9002}"
Mar 30 04:02:03 contiv-node3 netmaster[19412]: time="Mar 30 04:02:03.239922359" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9003}"
Mar 30 04:02:03 contiv-node3 netmaster[19412]: time="Mar 30 04:02:03.242355700" level=info msg="Registered node: &{HostAddr:192.168.2.53 HostPort:9002}"
Mar 30 04:02:21 contiv-node3 netmaster[19412]: time="Mar 30 04:02:21.572363645" level=info msg="Received EndpointUpdateRequest {{IPAddress: ContainerID: Labels...onName:}}"
Hint: Some lines were ellipsized, use -l to show in full.


[vagrant@contiv-node3 ~]$ sudo service netplugin status
Redirecting to /bin/systemctl status  netplugin.service
● netplugin.service - Netplugin
   Loaded: loaded (/etc/systemd/system/netplugin.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2017-03-30 04:00:42 UTC; 8min ago
 Main PID: 18810 (netplugin)
   CGroup: /system.slice/netplugin.service
           └─18810 /usr/bin/netplugin -plugin-mode docker -vlan-if eth2 -vtep-ip 192.168.2.52 -ctrl-ip 192.168.2.52 -cluster-store etcd://192.168.2.52:2379

Mar 30 04:02:21 contiv-node3 netplugin[18810]: time="Mar 30 04:02:21.161330412" level=info msg="Link up received for eth2"
Mar 30 04:02:21 contiv-node3 netplugin[18810]: time="Mar 30 04:02:21.568484116" level=info msg="Returning network name host for ID 422bc594582f5f711281f593ff19...596376d73"
Mar 30 04:02:21 contiv-node3 netplugin[18810]: time="Mar 30 04:02:21.568525462" level=info msg="Sending Endpoint update request to master: {&{IPAddress: Contai...onName:}}"
Mar 30 04:02:21 contiv-node3 netplugin[18810]: time="Mar 30 04:02:21.571034836" level=info msg="Making REST request to url: http://192.168.2.52:9999/plugin/updateEndpoint"
Mar 30 04:02:21 contiv-node3 netplugin[18810]: time="Mar 30 04:02:21.573488725" level=info msg="Results for (http://192.168.2.52:9999/plugin/updateEndpoint): &{IPAddress:}
Mar 30 04:02:21 contiv-node3 netplugin[18810]: "
Mar 30 04:03:06 contiv-node3 netplugin[18810]: time="Mar 30 04:03:06.113998515" level=info msg="Link up received for eth2"
Mar 30 04:03:06 contiv-node3 netplugin[18810]: time="Mar 30 04:03:06.126356395" level=info msg="Link up received for eth2"
Mar 30 04:03:51 contiv-node3 netplugin[18810]: time="Mar 30 04:03:51.114258889" level=info msg="Link up received for eth2"
Mar 30 04:08:51 contiv-node3 netplugin[18810]: time="Mar 30 04:08:51.170318252" level=info msg="Link up received for eth2"
Hint: Some lines were ellipsized, use -l to show in full.
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


```
[vagrant@contiv-node3 ~]$ ifconfig docker0
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        ether 02:42:72:6c:8d:f7  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[vagrant@contiv-node3 ~]$ ifconfig eth1
eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.52  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::a00:27ff:feb6:8af9  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:b6:8a:f9  txqueuelen 1000  (Ethernet)
        RX packets 17210  bytes 8681707 (8.2 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9908  bytes 2438902 (2.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[vagrant@contiv-node3 ~]$ ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::5054:ff:fe1f:dbb7  prefixlen 64  scopeid 0x20<link>
        ether 52:54:00:1f:db:b7  txqueuelen 1000  (Ethernet)
        RX packets 203696  bytes 186767867 (178.1 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 77560  bytes 4354377 (4.1 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```


In the above output, you'll see:
- `docker0` interface corresponds to the linux bridge and its associated
subnet `172.17.0.1/16`. This is created by docker daemon automatically, and
is the default network containers would belong to when an override network
is not specified
- `eth0` in this VM is the management interface, on which we ssh into the VM
- `eth1` in this VM is the interface that connects to external network (if needed)
- `eth2` in this VM is the interface that carries vxlan and control (e.g. etcd) traffic


### Chapter 1 - Introduction to Container Networking

There are two main container networking model discussed within the community.

#### Docker libnetwork - Container Network Model (CNM)

CNM (Container Network Model) is Docker's libnetwork network model for containers
- An endpoint is container's interface into a network
- A network is collection of arbitrary endpoints
- A container can belong to multiple endpoints (and therefore multiple networks)
- CNM allows for co-existence of multiple drivers, with a network managed by one driver
- Provides Driver APIs for IPAM and Endpoint creation/deletion
- IPAM Driver APIs: Create/Delete Pool, Allocate/Free IP Address
- Network Driver APIs: Network Create/Delete, Endpoint Create/Delete/Join/Leave
- Used by docker engine, docker swarm, and docker compose; and other schedulers
that schedules regular docker containers e.g. Nomad or Mesos docker containerizer

#### CoreOS CNI - Container Network Interface (CNI)
CNI (Container Network Interface) CoreOS's network model for containers
- Allows container id (uuid) specification for the network interface you create
- Provides Container Create/Delete events
- Provides access to network namespace to the driver to plumb networking
- No separate IPAM Driver: Container Create returns the IAPM information along with other data
- Used by Kubernetes and thus supported by various Kubernetes network plugins, including Contiv

Using Contiv with CNI/Kubernetes can be found [here](https://github.com/contiv/netplugin/tree/master/mgmtfn/k8splugin).
The rest of the tutorial walks through the docker examples, which implements CNM APIs

#### Basic container networking

Let's examine the networking a container gets upon vanilla run

```
[vagrant@contiv-node3 ~]$ docker network ls
NETWORK ID          NAME                  DRIVER              SCOPE
a1729504b2d1        contiv-node3/bridge   bridge              local
422bc594582f        contiv-node3/host     host                local
5d6b06097745        contiv-node3/none     null                local
7dc18de21668        contiv-node4/bridge   bridge              local
72680804a591        contiv-node4/host     host                local
18b816723b79        contiv-node4/none     null                local

[vagrant@contiv-node3 ~]$ docker run -itd --name=vanilla-c alpine /bin/sh
58d5fe78d517834b0172b7ca90521e058680cf3de1fc7824cf66a097c1cffc11

**Note**:
- Please note this container got scheduled by docker swarm on contiv-node4. 
Run `docker ps` and check NAMES column to find it.

**
[vagrant@contiv-node3 ~]$ ifconfig 
```

In the `ifconfig` output, you will see that it would have created a veth `virtual 
ethernet interface` that could look like `veth......` towards the end. More 
importantly it is allocated an IP address from default docker bridge `docker0`, 
likely `172.17.0.5` in this setup, and can be examined using

```
[vagrant@contiv-node3 ~]$ docker network inspect contiv-node4/bridge
[
    {
        "Name": "bridge",
        "Id": "7dc18de21668de453dd696de5a130b59c3afe7d79dfca2ed10b3919f12474eff",
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
            "58d5fe78d517834b0172b7ca90521e058680cf3de1fc7824cf66a097c1cffc11": {
                "Name": "vanilla-c",
                "EndpointID": "f0feb63de2465891fe8b2f94141b79b47865e9f048f395b1c323555a5314b3f8",
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

[vagrant@contiv-node3 ~]$ docker inspect --format '{{.NetworkSettings.IPAddress}}' vanilla-c
172.17.0.2
```

The other pair of veth interface is put into the container with the name `eth0`

```
[vagrant@contiv-node3 ~]$ docker inspect --format '{{.NetworkSettings.IPAddress}}' vanilla-c
172.17.0.2
[vagrant@contiv-node3 ~]$ docker exec -it vanilla-c /bin/sh
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
[vagrant@contiv-node3 ~]$ sudo iptables -t nat -L -n
```

### Chapter 2: Multi-host networking

There are many solutions like Contiv such as Calico, Weave, OpenShift, OpenContrail, Nuage,
VMWare, Docker, Kubernetes, OpenStack that provide solutions to multi-host
container networking. 

In this section, let's examine Contiv and Docker overlay solutions.

#### Multi-host networking with Contiv
Let's use the same example as above to spin up two containers on the two different hosts

#### 1. Create a multi-host network

```
[vagrant@contiv-node3 ~]$ netctl net create --subnet=10.1.2.0/24 contiv-net
[vagrant@contiv-node3 ~]$ netctl net ls
Tenant   Network     Nw Type  Encap type  Packet tag  Subnet       Gateway
------   -------     -------  ----------  ----------  -------      ------
default  contiv-net  data     vxlan       0           10.1.2.0/24  

[vagrant@contiv-node3 ~]$ docker network ls
NETWORK ID          NAME                  DRIVER              SCOPE
c7b8c135c9f1        contiv-net            netplugin           global
a1729504b2d1        contiv-node3/bridge   bridge              local
422bc594582f        contiv-node3/host     host                local
5d6b06097745        contiv-node3/none     null                local
7dc18de21668        contiv-node4/bridge   bridge              local
72680804a591        contiv-node4/host     host                local
18b816723b79        contiv-node4/none     null                local   

[vagrant@contiv-node3 ~]$ docker network inspect contiv-net
[
    {
        "Name": "contiv-net",
        "Id": "c7b8c135c9f1b94614db84875b95873c833af56b2aac0606a88d2497ccb2a055",
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

You can now spin a couple of containers belonging to `contiv-net` network. Specifying node constraint forces containers to start on different hosts.

```
[vagrant@contiv-node3 ~]$ docker run -itd --name=contiv-c1 --net=contiv-net -e constraint:node=contiv-node3 alpine /bin/sh
09689c15f6410c049e16d60cfe42926009af163aeb4296569cb17869a5b69732

[vagrant@contiv-node3 ~]$ docker run -itd --name=contiv-c2 --net=contiv-net -e constraint:node=contiv-node4 alpine /bin/sh
f09a78e7960d6c1dfbf86e85648c44479681ef22a86e3049dc2296178ece9c7f

[vagrant@contiv-node3 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
09689c15f641        alpine                           "/bin/sh"                3 seconds ago       Up 1 seconds                            contiv-node3/contiv-c1
f09a78e7960d        alpine                           "/bin/sh"                3 minutes ago       Up 3 minutes                            contiv-node4/contiv-c2

[vagrant@contiv-node3 ~]$ docker exec -it contiv-c2 /bin/sh
/ #
/ # ping contiv-c1
PING contiv-c1 (10.1.2.1): 56 data bytes
64 bytes from 10.1.2.1: seq=0 ttl=64 time=4.236 ms
64 bytes from 10.1.2.1: seq=1 ttl=64 time=0.941 ms
^C
--- contiv-c1 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.941/2.588/4.236 ms
/ # exit
```

As you will see during the ping that, built in dns resolves the name `contiv-c1`
to the IP address of `contiv-c1` container and be able to reach another container
across using a vxlan overlay.


#### Docker Overlay multi-host networking

Docker engine has a built in overlay driver that can be use to connect
containers across multiple nodes. However since vxlan port used by `contiv`
driver is same as that of `overlay` driver from Docker, we will use
Docker's overlay multi-host networking towards the end after we experiment
with `contiv` because then we can terminate the contiv driver and
let Docker overlay driver use the vxlan port bindings. More about it in
later chapter.

### Chapter 3: Using multiple tenants with arbitrary IPs in the networks

First, let's create a new tenant space.

```
[vagrant@contiv-node3 ~]$ export DOCKER_HOST=tcp://192.168.2.52:2375
[vagrant@contiv-node3 ~]$ netctl tenant create blue
Creating tenant: blue                  

[vagrant@contiv-node3 ~]$ netctl tenant ls
Name
------
default
blue
```

After the tenant is created, we can create network within tenant `blue`.
Here we can choose the same subnet and network name as we used earlier with default tenant, as namespaces
are isolated across tenants.

```
[vagrant@contiv-node3 ~]$ netctl net create -t blue --subnet=10.1.2.0/24 contiv-net
Creating network blue:contiv-net
[vagrant@contiv-node3 ~]$ netctl net ls -t blue
Tenant  Network     Nw Type  Encap type  Packet tag  Subnet       Gateway  IPv6Subnet  IPv6Gateway
------  -------     -------  ----------  ----------  -------      ------   ----------  -----------
blue    contiv-net  data     vxlan       0           10.1.2.0/24
```

Next, we can run containers belonging to this tenant.

```
[vagrant@contiv-node3 ~]$ docker run -itd --name=contiv-blue-c1 --net="contiv-net/blue" alpine /bin/sh
224be352b574493336e8570b8925a359f808fc05f98b791ca5b14ec9ed580339

[vagrant@contiv-node3 ~]$ docker run -itd --name=contiv-blue-c2 --net="contiv-net/blue" alpine /bin/sh
be63dbd230d6062a07ba63e0ec1af047d4a1181b4003b64a1e5b42ab019c1f43

[vagrant@contiv-node3 ~]$ docker run -itd --name=contiv-blue-c3 --net="contiv-net/blue" alpine /bin/sh
1db8d18a88fe976f007e49bcb68e4e7d10ff0d08a2f7ff2ef3e3ac2b00cccc52

[vagrant@contiv-node3 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
1db8d18a88fe        alpine                           "/bin/sh"                15 seconds ago      Up 14 seconds                           contiv-node4/contiv-blue-c3
be63dbd230d6        alpine                           "/bin/sh"                58 seconds ago      Up 56 seconds                           contiv-node3/contiv-blue-c2
224be352b574        alpine                           "/bin/sh"                2 minutes ago       Up 2 minutes                            contiv-node4/contiv-blue-c1
f09a78e7960d        alpine                           "/bin/sh"                8 minutes ago       Up 7 minutes                            contiv-node3/contiv-c2
09689c15f641        alpine                           "/bin/sh"                11 minutes ago      Up 11 minutes                           contiv-node4/contiv-c1
58d5fe78d517        alpine                           "/bin/sh"                45 minutes ago      Up 45 minutes                           contiv-node4/vanilla-c
8e08d18caf2c        contiv/auth_proxy:1.0.0-beta.4   "./auth_proxy --tls-k"   About an hour ago   Up About an hour                        contiv-node3/auth-proxy
77943d7f8a84        quay.io/coreos/etcd:v2.3.8       "/etcd"                  About an hour ago   Up About an hour                        contiv-node4/etcd
1a266627540f        quay.io/coreos/etcd:v2.3.8       "/etcd"                  About an hour ago   Up About an hour                        contiv-node3/etcd

[vagrant@contiv-node3 ~]$ docker network inspect contiv-net/blue
[
    {
        "Name": "contiv-net/blue",
        "Id": "...",
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
            "...": {
                "Name": "contiv-blue-c3",
                "EndpointID": "...",
                "MacAddress": "02:02:0a:01:02:03",
                "IPv4Address": "10.1.2.3/24",
                "IPv6Address": ""
            },
            "...": {
                "Name": "contiv-blue-c1",
                "EndpointID": "...",
                "MacAddress": "02:02:0a:01:02:01",
                "IPv4Address": "10.1.2.1/24",
                "IPv6Address": ""
            },
            "...": {
                "Name": "contiv-blue-c2",
                "EndpointID": "...",
                "MacAddress": "02:02:0a:01:02:02",
                "IPv4Address": "10.1.2.2/24",
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

[vagrant@contiv-node3 ~]$ docker exec -it contiv-blue-c3 /bin/sh
/ # ping contiv-blue-c1
PING contiv-blue-c1 (10.1.2.1): 56 data bytes
64 bytes from 10.1.2.1: seq=0 ttl=64 time=1.105 ms
64 bytes from 10.1.2.1: seq=1 ttl=64 time=0.089 ms
64 bytes from 10.1.2.1: seq=2 ttl=64 time=0.106 ms
^C
--- contiv-blue-c1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.089/0.433/1.105 ms
/ # ping contiv-blue-c2
PING contiv-blue-c2 (10.1.2.2): 56 data bytes
64 bytes from 10.1.2.2: seq=0 ttl=64 time=2.478 ms
64 bytes from 10.1.2.2: seq=1 ttl=64 time=1.054 ms
64 bytes from 10.1.2.2: seq=2 ttl=64 time=0.895 ms
^C
--- contiv-blue-c2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.895/1.475/2.478 ms

/ # exit
```

### Chapter 4: Connecting containers to external networks

In this chapter, we explore ways to connect containers to the external networks

#### 1. External Connectivity using Host NATing

Docker uses the linux bridge (docker_gwbridge) based PNAT to reach out and port mappings
for others to reach to the container

```
[vagrant@contiv-node4 ~]$ docker exec -it contiv-c1 /bin/sh
/ # ifconfig -a
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:02:01
          inet addr:10.1.2.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:201/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:19 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1534 (1.4 KiB)  TX bytes:886 (886.0 B)

eth1      Link encap:Ethernet  HWaddr 02:42:AC:12:00:02
          inet addr:172.18.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe12:2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:31 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2466 (2.4 KiB)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # ping contiv.com
PING contiv.com (216.239.32.21): 56 data bytes
64 bytes from 216.239.32.21: seq=0 ttl=61 time=33.051 ms
64 bytes from 216.239.32.21: seq=1 ttl=61 time=41.745 ms
^C
--- contiv.com ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 33.051/37.398/41.745 ms

/ # exit
```

What you see is that container has two interfaces belonging to it:
- eth0 is reachability into the `contiv-net` 
- eth1 is reachability for container to the external world and outside
traffic to be able to reach the container `contiv-c1`. This also relies on the host's dns
resolv.conf as a default way to resolve non container IP resolution.

Similarly outside traffic can be exposed on specific ports using `-p` command. Before
we do that, let us confirm that port 9099 is not reachable from the host
`contiv-node3`. To install `nc` netcat utility please run `sudo yum -y install nc and sudo yum -y install tcpdump` on contiv-node3


```
# Install nc utility
[vagrant@contiv-node3 ~]$ sudo yum -y install nc
< some yum install output >
Complete!

[vagrant@contiv-node3 ~]$ sudo yum -y install tcpdump
< some yum install output >
Complete!

[vagrant@contiv-node3 ~]$ nc -vw 1 localhost 9099
Ncat: Version 6.40 ( http://nmap.org/ncat )
Ncat: Connection refused.
```

Now we start a container that exposes tcp port 9099 out in the host.

```
[vagrant@contiv-node3 ~]$ docker run -itd -p 9099:9099 --name=contiv-exposed --net=contiv-net alpine /bin/sh
a36a8c3eda6675582d9c3f77b30dd50d8d9592bf20919f57d7b4e70ed8d8ff49
```

And if we re-run our `nc` utility, we'll see that 9099 is reachable.

```
[vagrant@contiv-node3 ~]$ nc -vw 1 localhost 9099
Ncat: Version 6.40 ( http://nmap.org/ncat )
Ncat: Connected to 127.0.0.1:9099.
^C
```

This happens because docker as soon as a port is exposed, a NAT rule is installed for
the port to allow rest of the network to access the container on the specified/exposed
port. The nat rules on the host can be seen by:

```
[vagrant@contiv-node3 ~]$ sudo iptables -t nat -L -n
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
[vagrant@contiv-node3 ~]$ netctl net create -p 112 -e vlan -s 10.1.3.0/24 contiv-vlan
Creating network default:contiv-vlan
[vagrant@contiv-node3 ~]$ netctl net ls
Tenant   Network      Nw Type  Encap type  Packet tag  Subnet       Gateway  IPv6Subnet  IPv6Gateway
------   -------      -------  ----------  ----------  -------      ------   ----------  -----------
default  contiv-vlan  data     vlan        112         10.1.3.0/24
default  contiv-net   data     vxlan       0           10.1.2.0/24  
```

The allocated vlan can be used to connect any workload in vlan 112 in the network infrastructure.
The interface that connects to the outside network needs to be specified during netplugin
start, for this VM configuration it is set as `eth2`

Let's run some containers to belong to this network, one on each node. First one on 
`contiv-node3`

```
[vagrant@contiv-node3 ~]$ docker run -itd --name=contiv-vlan-c1 --net=contiv-vlan alpine /bin/sh
830e9ee01f2e7c64e51b10bc3990d03c6b5ec22d28985c3f49552ad93fc75d74
```

And another one on `contiv-node4`

```
[vagrant@contiv-node4 ~]$ docker run -itd --name=contiv-vlan-c2 --net=contiv-vlan alpine /bin/sh
a4fcd337342888520e0886d3f2cd304d78d1d8657ba868503b357dc6e5227476

[vagrant@contiv-node4 ~]$ docker exec -it contiv-vlan-c2 /bin/sh

/ # ping contiv-vlan-c1
PING contiv-vlan-c1 (10.1.3.1): 56 data bytes
64 bytes from 10.1.3.1: seq=0 ttl=64 time=3.051 ms
64 bytes from 10.1.3.1: seq=1 ttl=64 time=0.893 ms
64 bytes from 10.1.3.1: seq=2 ttl=64 time=0.840 ms
64 bytes from 10.1.3.1: seq=3 ttl=64 time=0.860 ms
64 bytes from 10.1.3.1: seq=4 ttl=64 time=0.836 ms
. . .
```

While this is going on `contiv-node4`, let's run tcpdump on eth2 on `contiv-node3`
and confirm how rx/tx packets look on it:

```
[vagrant@contiv-node3 ~]$ sudo tcpdump -e -i eth2 icmp
tcpdump: WARNING: eth2: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), capture size 65535 bytes
05:13:57.641958 02:02:0a:01:03:01 (oui Unknown) > 02:02:0a:01:03:02 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.1 > 10.1.3.2: ICMP echo reply, id 2560, seq 0, length 64
05:13:58.642954 02:02:0a:01:03:01 (oui Unknown) > 02:02:0a:01:03:02 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.1 > 10.1.3.2: ICMP echo reply, id 2560, seq 1, length 64
05:13:59.643342 02:02:0a:01:03:01 (oui Unknown) > 02:02:0a:01:03:02 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 112, p 0, ethertype IPv4, 10.1.3.1 > 10.1.3.2: ICMP echo reply, id 2560, seq 2, length 64
^C
3 packets captured
3 packets received by filter
0 packets dropped by kernel
```

Note: The vlan shown in tcpdump is same (i.e. `112`) as what we configured in the VLAN. After verifying this, feel free to stop the ping that is still running on 
`contiv-vlan-c2` container.


### Chapter 5: Docker Overlay multi-host networking

As we learned earlier that using the vxlan port conflict can prevent us from using
Docker `overlay` network. For us to experiment with this, we'd go ahead
and terminate `contiv` driver first on both nodes: `contiv-node3` and
`contiv-node4`:

```
[vagrant@contiv-node3 ~]$ sudo service netplugin stop
Redirecting to /bin/systemctl stop  netplugin.service
```

To try out overlay driver, we switch to `contiv-node3` and create an overlay network first.

```
[vagrant@contiv-node3 ~]$ docker network create -d=overlay --subnet=30.1.1.0/24 overlay-net
464aa012989d0736d277b5be55b7685ae42e36350fd3c8ae121721753edb497a

[vagrant@contiv-node3 ~]$ docker network inspect overlay-net
[
    {
        "Name": "overlay-net",
        "Id": "464aa012989d0736d277b5be55b7685ae42e36350fd3c8ae121721753edb497a",
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
[vagrant@contiv-node3 ~]$ docker run -itd --name=overlay-c1 --net=overlay-net alpine /bin/sh
82079ffd25d45731d0e1e3691211c055977c4e44e5ce1e0bea2c95ab9881fb02

[vagrant@contiv-node3 ~]$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' overlay-c1
30.1.1.2

[vagrant@contiv-node3 ~]$ docker run -itd --name=overlay-c2 --net=overlay-net alpine /bin/sh
825a80fb54c4360e48dbe1057a9682273df2811028ec5876cf26124024f6a702

[vagrant@contiv-node3 ~]$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS               NAMES
825a80fb54c4        alpine                           "/bin/sh"                38 seconds ago       Up 37 seconds                           contiv-node4/overlay-c2
82079ffd25d4        alpine                           "/bin/sh"                About a minute ago   Up About a minute                       contiv-node4/overlay-c1
cf720d2e5409        contiv/auth_proxy:1.0.0-beta.5   "./auth_proxy --tls-k"   3 hours ago          Up 3 hours                              contiv-node3/auth-proxy
2d450e95bb3b        quay.io/coreos/etcd:v2.3.8       "/etcd"                  4 hours ago          Up 4 hours                              contiv-node4/etcd
78c09b21c1fa        quay.io/coreos/etcd:v2.3.8       "/etcd"                  4 hours ago          Up 4 hours                              contiv-node3/etcd

[vagrant@contiv-node3 ~]$ docker exec -it overlay-c2 /bin/sh
/ # ping overlay-c1
PING overlay-c1 (30.1.1.2): 56 data bytes
64 bytes from 30.1.1.2: seq=0 ttl=64 time=0.096 ms
64 bytes from 30.1.1.2: seq=1 ttl=64 time=0.091 ms
64 bytes from 30.1.1.2: seq=2 ttl=64 time=0.075 ms
^C
--- overlay-c1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.075/0.087/0.096 ms

/ # exit
```

Very similar to contiv-networking, built in dns resolves the name `overlay-c1`
to the IP address of `overlay-c1` container and be able to reach another container
across using a vxlan overlay.

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

### References
1. [CNI Specification](https://github.com/containernetworking/cni/blob/master/SPEC.md)
2. [CNM Design](https://github.com/docker/libnetwork/blob/master/docs/design.md)
3. [Contiv User Guide](http://docs.contiv.io)
4. [Contiv Networking Code](https://github.com/contiv/netplugin)


### Improvements or Comments
This tutorial was developed by Contiv engineers. Thank you for trying out this tutorial.
Please file a GitHub issue if you see an issue with the tutorial, or if you prefer
improving some text, feel free to send a pull request.
