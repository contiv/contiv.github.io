
## Containers Networking Tutorial with Contiv
This tutorial walks you through container networking and concepts step by step. We will also explore Contiv's networking features along with policies.

### Lab Setup

In this lab we are going to use two VMs which are hosted on Cisco's UCS servers. Those are running on ESX. Through vswitch those are connected to TOR switches.

![Lab Setup](https://github.com/contiv/contiv.github.io/blob/master/extras/Dockercon-2017/Lab-Setup.png?raw=true)

### Contiv Installation

The Contiv Docker Swarm installer is launched from a host external to the cluster.  All the nodes must be accessible to the Contiv Ansible-based installer host through SSH.

![installer](https://github.com/contiv/install/blob/master/installer.png?raw=true)

**Note**:
- Please make sure that you are logged on `Installer-Host` machine, and perform the following steps.

#### Step 1: Setup passwordless SSH from Installer-Host to other nodes.

```
mkdir .ssh && chmod 700 .ssh

ssh-keygen -t rsa -f ~/.ssh/id_rsa  -N ""

sshpass -p cisco.123 ssh-copy-id -i ~/.ssh/id_rsa.pub root@pod19-srv1.ecatsrtpdmz.cisco.com -o StrictHostKeyChecking=no

sshpass -p cisco.123 ssh-copy-id -i ~/.ssh/id_rsa.pub root@pod19-srv2.ecatsrtpdmz.cisco.com -o StrictHostKeyChecking=no

```

#### Step 2: Get contiv installer from github. 


```
cd ~
wget https://github.com/contiv/install/releases/download/1.0.0/contiv-1.0.0.tgz
tar -zxvf contiv-1.0.0.tgz

```



#### Step 3: Create config file to install contiv

```
cat << EOF > ~/cfg.yml
CONNECTION_INFO:
      pod19-srv1.ecatsrtpdmz.cisco.com:
        role: master
        control: eth0
        data: eth1
      pod19-srv2.ecatsrtpdmz.cisco.com:
        control: eth0
        data: eth1
EOF

```

#### Step 4: Install contiv on pod19-srv1 and pod19-srv2

```
cd ~/contiv-1.0.0

./install/ansible/install_swarm.sh -f ~/cfg.yml -e ~/.ssh/id_rsa -u root -i

```

Some examples of installer:

```
Examples:
1. Uninstall Contiv and Docker Swarm on hosts specified by cfg.yml.
./install/ansible/uninstall_swarm.sh -f cfg.yml -e ~/ssh_key -u admin -i
2. Uninstall Contiv and Docker Swarm on hosts specified by cfg.yml for an ACI setup.
./install/ansible/uninstall_swarm.sh -f cfg.yml -e ~/ssh_key -u admin -i -m aci
3. Uninstall Contiv and Docker Swarm on hosts specified by cfg.yml for an ACI setup, remove all containers and Contiv etcd state
./install/ansible/uninstall_swarm.sh -f cfg.yml -e ~/ssh_key -u admin -i -m aci -r

```

**Note**:
- For next set of steps, We will be logging in on pod19-srv1 and pod19-srv2.


#### Step 4: Hello world Docker swarm.

As a part of this contiv installation, we install docker swarm for you. 

To verify docker swarm cluster, let us perform following steps.
**Note**:
- Make sure you execute following step on pod19-srv1 as well as pod19-srv2


```
On pod19-srv1:

[root@pod19-srv1 ~]# export DOCKER_HOST=tcp://pod19-srv1.ecatsrtpdmz.cisco.com:2375

On pod19-srv2:

[root@pod19-srv2 ~]# export DOCKER_HOST=tcp://pod19-srv1.ecatsrtpdmz.cisco.com:2375

```

Now verify that swarm is running successfully or not.

```
[root@pod19-srv2 ~]# docker info
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
 pod19-srv1.ecatsrtpdmz.cisco.com: 10.0.236.45:2385
  └ ID: 6YBU:MWOG:QCWK:34U3:JUUT:BBP7:LWEH:UHXW:L4ES:SOVZ:AIMA:LD5K
  └ Status: Healthy
  └ Containers: 4 (4 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 8.022 GiB
  └ Labels: kernelversion=3.10.0-514.6.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-04-12T00:10:22Z
  └ ServerVersion: 1.12.6
 pod19-srv2.ecatsrtpdmz.cisco.com: 10.0.236.77:2385
  └ ID: X46T:2DNF:MZGH:W5S4:VBLM:ENJN:DUV4:IOJQ:MLJL:KK5E:LW7D:XADB
  └ Status: Healthy
  └ Containers: 2 (2 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 8.022 GiB
  └ Labels: kernelversion=3.10.0-514.6.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ UpdatedAt: 2017-04-12T00:10:17Z
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
Total Memory: 16.04 GiB
Name: pod19-srv1.ecatsrtpdmz.cisco.com
Docker Root Dir: 
Debug Mode (client): false
Debug Mode (server): false
WARNING: No kernel memory limit support

```

Docker swarm with 2 nodes is running successfully.

#### Step 5: Check contiv and related services.

`etcdctl` is a control utility to manipulate etcd, state store used by kubernetes/docker/contiv

To check etcd cluster health

```
[root@pod19-srv1 ~]# etcdctl cluster-health
member 3617459f1e4ec4e4 is healthy: got healthy result from http://10.0.236.45:2379
cluster is healthy

```

To check netplugin and netmaster is running successfully.

```
[root@pod19-srv1 ~]# sudo service netmaster status
Redirecting to /bin/systemctl status  netmaster.service
● netmaster.service - Netmaster
   Loaded: loaded (/etc/systemd/system/netmaster.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2017-04-11 20:09:12 EDT; 2min 52s ago
 Main PID: 16103 (netmaster)
   CGroup: /system.slice/netmaster.service
           └─16103 /usr/bin/netmaster --cluster-mode docker -cluster-store etcd://10.0.236.45:2379

Apr 11 20:09:47 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:47.940208005" level=info msg="Connecting to RPC server: 10.0.236.77:9002"
Apr 11 20:09:47 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:47.943741660" level=info msg="Connected to RPC server: 10.0.236.77:9002"
Apr 11 20:09:47 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:47.944169893" level=info msg="Registered node: &{HostAddr:10.0.236.77 HostPort:9002}"
Apr 11 20:09:47 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:47.947737457" level=info msg="Sending service add event: {ServiceName:netplugin Role: Version: TTL:10 HostAddr:10.0.236.77 Port:90...mz.cisco.com}"
Apr 11 20:09:48 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:48.045712382" level=info msg="Connecting to RPC server: 10.0.236.77:9003"
Apr 11 20:09:48 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:48.046161489" level=info msg="Connected to RPC server: 10.0.236.77:9003"
Apr 11 20:09:48 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:48.046981346" level=info msg="Registered node: &{HostAddr:10.0.236.77 HostPort:9003}"
Apr 11 20:09:50 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:50.268556177" level=info msg="Registered node: &{HostAddr:10.0.236.77 HostPort:9003}"
Apr 11 20:09:50 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:09:50.269670879" level=info msg="Registered node: &{HostAddr:10.0.236.77 HostPort:9002}"
Apr 11 20:10:04 pod19-srv1.ecatsrtpdmz.cisco.com netmaster[16103]: time="Apr 11 20:10:04.142642185" level=info msg="Received EndpointUpdateRequest {{IPAddress: ContainerID: Labels:map[] Tenant: Network: Event: Endpoi...CommonName:}}"
Hint: Some lines were ellipsized, use -l to show in full.


[root@pod19-srv1 ~]# sudo service netplugin status
Redirecting to /bin/systemctl status  netplugin.service
● netplugin.service - Netplugin
   Loaded: loaded (/etc/systemd/system/netplugin.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2017-04-11 20:09:08 EDT; 3min 7s ago
 Main PID: 15613 (netplugin)
   CGroup: /system.slice/netplugin.service
           └─15613 /usr/bin/netplugin -plugin-mode docker -vlan-if eth1 -vtep-ip 10.0.236.45 -ctrl-ip 10.0.236.45 -cluster-store etcd://10.0.236.45:2379

Apr 11 20:09:47 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:09:47.938448472" level=info msg="Node add event for {{ServiceName:netplugin.vtep Role: Version: TTL:10 HostAddr:10.0.236.77 Port:4789 Hostname:}}"
Apr 11 20:09:47 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:09:47.938461859" level=info msg="CreatePeerHost for {HostAddr:10.0.236.77 Port:4789}"
Apr 11 20:09:47 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:09:47.938486313" level=info msg="Creating VTEP intf vxif10023677 for IP 10.0.236.77"
Apr 11 20:09:48 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:09:48.243831933" level=info msg="Received Add VTEP port(2), Remote IP: 10.0.236.77"
Apr 11 20:10:03 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:10:03.339015655" level=error msg="Error getting docknet list. Err: Key not found [github.com/contiv/netplugin/state.(*EtcdStateDriver...river.go 155]"
Apr 11 20:10:04 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:10:04.137013811" level=info msg="Returning network name host for ID e8be04ef7ab7a4e60aa9fe099d0f5ab5f02d202a4500cb660e897a3a2db5117b"
Apr 11 20:10:04 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:10:04.137055877" level=info msg="Sending Endpoint update request to master: {&{IPAddress: ContainerID: Labels:map[] Tenant: Network: ...CommonName:}}"
Apr 11 20:10:04 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:10:04.138157544" level=info msg="Making REST request to url: http://10.0.236.45:9999/plugin/updateEndpoint"
Apr 11 20:10:04 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: time="Apr 11 20:10:04.143355825" level=info msg="Results for (http://10.0.236.45:9999/plugin/updateEndpoint): &{IPAddress:}
Apr 11 20:10:04 pod19-srv1.ecatsrtpdmz.cisco.com netplugin[15613]: "
Hint: Some lines were ellipsized, use -l to show in full.


```

`netctl` is a utility to create, update, read and modify contiv objects. It is a CLI wrapper
on top of REST interface.


```
[root@pod19-srv1 ~]# netctl version
Client Version:
Version: 1.0.0
GitCommit: aa79db4
BuildTime: 04-06-2017.11-39-44.UTC

Server Version:
Version: 1.0.0
GitCommit: e820dd7
BuildTime: 02-17-2017.23-55-08.UTC
[root@pod19-srv1 ~]# 

```
--------------------------------------------------------------------------------------------

```
[root@pod19-srv1 ~]# ifconfig docker0
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        ether 02:42:eb:69:4b:d0  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[root@pod19-srv1 ~]# ifconfig eth1
eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::9a0:86d9:2017:5c43  prefixlen 64  scopeid 0x20<link>
        ether 00:50:56:8c:4e:6b  txqueuelen 1000  (Ethernet)
        RX packets 980097  bytes 335123188 (319.5 MiB)
        RX errors 0  dropped 103  overruns 0  frame 0
        TX packets 389896  bytes 69068232 (65.8 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

[root@pod19-srv1 ~]# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.236.45  netmask 255.255.255.0  broadcast 10.0.236.255
        inet6 fe80::250:56ff:fe0c:129  prefixlen 64  scopeid 0x20<link>
        ether 00:50:56:0c:01:29  txqueuelen 1000  (Ethernet)
        RX packets 9672470  bytes 762570103 (727.2 MiB)
        RX errors 0  dropped 3168  overruns 0  frame 0
        TX packets 88587  bytes 7139143 (6.8 MiB)
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


#### Basic container networking

Let's examine the networking a container gets upon vanilla run

```
[root@pod19-srv1 ~]# docker network ls
NETWORK ID          NAME                                      DRIVER              SCOPE
4c7a511c1131        pod19-srv1.ecatsrtpdmz.cisco.com/bridge   bridge              local               
e8be04ef7ab7        pod19-srv1.ecatsrtpdmz.cisco.com/host     host                local               
632ec424d389        pod19-srv1.ecatsrtpdmz.cisco.com/none     null                local               
ffa83d536aba        pod19-srv2.ecatsrtpdmz.cisco.com/bridge   bridge              local               
43f4fb17d806        pod19-srv2.ecatsrtpdmz.cisco.com/host     host                local               
dce44a32c67d        pod19-srv2.ecatsrtpdmz.cisco.com/none     null                local  

[root@pod19-srv1 ~]# docker run -itd --name=vanilla-c alpine /bin/sh
36f04a36338c8b1e6c6cb25b621e475eb940ba36fe058305caa5c02ca0b02c3f

```

**Note**:
- Please run `docker ps` and check NAMES column to find that this
container got scheduled by docker swarm on which node. Here you can see that this container
got scheduled on pod19-srv2 node.

```
[root@pod19-srv1 ~]# docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
36f04a36338c        alpine                           "/bin/sh"                15 seconds ago      Up 12 seconds                           pod19-srv2.ecatsrtpdmz.cisco.com/vanilla-c
7a4218de54c7        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   5 minutes ago       Up 5 minutes                            pod19-srv1.ecatsrtpdmz.cisco.com/auth-proxy
e7b6621a8257        quay.io/coreos/etcd:v2.3.8       "/etcd"                  7 minutes ago       Up 7 minutes                            pod19-srv2.ecatsrtpdmz.cisco.com/etcd
228913a30a93        quay.io/coreos/etcd:v2.3.8       "/etcd"                  7 minutes ago       Up 7 minutes                            pod19-srv1.ecatsrtpdmz.cisco.com/etcd

```

In the ifconfig output, you will see that it would have created a veth virtual ethernet interface 
that could look like veth...... towards the end. 
More importantly it is allocated an IP address from default docker bridge docker0, likely 172.17.0.5 in this setup, and can be examined using

Let us inspect one of the network

```
[root@pod19-srv2 ~]# docker network inspect pod19-srv1.ecatsrtpdmz.cisco.com/bridge
[
    {
        "Name": "bridge",
        "Id": "4c7a511c1131a82f114293921422ad940e2594379f28c07f3d53347e4c3e11ac",
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
        "Containers": {},
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

[root@pod19-srv2 ~]# docker inspect --format '{{.NetworkSettings.IPAddress}}' vanilla-c
172.17.0.2

```

The other pair of veth interface is put into the container with the name `eth0`

```
[root@pod19-srv2 ~]# docker inspect --format '{{.NetworkSettings.IPAddress}}' vanilla-c
172.17.0.2
[root@pod19-srv2 ~]# docker exec -it vanilla-c /bin/sh
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
[root@pod19-srv2 ~]# sudo iptables -t nat -L -n

```

### Chapter 2: Multi-host networking

Contiv is the best multi host policy networking for docker containers. 

In this section, let's examine Contiv and Docker overlay solutions.

#### Multi-host networking with Contiv
Let's use the same example as above to spin up two containers on the two different hosts

#### 1. Create a multi-host network

```
[root@pod19-srv2 ~]# netctl net create --subnet=30.1.2.0/24 contiv-net
Creating network default:contiv-net
[root@pod19-srv2 ~]# netctl network ls 
Tenant   Network     Nw Type  Encap type  Packet tag  Subnet       Gateway  IPv6Subnet  IPv6Gateway
------   -------     -------  ----------  ----------  -------      ------   ----------  -----------
default  contiv-net  data     vxlan       0           30.1.2.0/24     

[root@pod19-srv2 ~]# docker network ls
NETWORK ID          NAME                                      DRIVER              SCOPE
d120aeb0010b        contiv-net                                netplugin           global              
4c7a511c1131        pod19-srv1.ecatsrtpdmz.cisco.com/bridge   bridge              local               
e8be04ef7ab7        pod19-srv1.ecatsrtpdmz.cisco.com/host     host                local               
632ec424d389        pod19-srv1.ecatsrtpdmz.cisco.com/none     null                local               
ffa83d536aba        pod19-srv2.ecatsrtpdmz.cisco.com/bridge   bridge              local               
43f4fb17d806        pod19-srv2.ecatsrtpdmz.cisco.com/host     host                local               
dce44a32c67d        pod19-srv2.ecatsrtpdmz.cisco.com/none     null                local       

[root@pod19-srv2 ~]# docker network inspect contiv-net
[
    {
        "Name": "contiv-net",
        "Id": "d120aeb0010bb825983983cea7ab4e88e5bf1656344d899b471c0e1bb6abb5c8",
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
                    "Subnet": "30.1.2.0/24"
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

You can now run a new container belonging to `contiv-net` network:

```
[root@pod19-srv2 ~]# docker run -itd --name=contiv-c1 --net=contiv-net alpine /bin/sh
e0d473622395e42c50c4e18ad96fc914afaec2e20b7b4e7c4c97a3328fcae765

[root@pod19-srv2 ~]# docker run -itd --name=contiv-c2 --net=contiv-net alpine /bin/sh
0c9ffe9225e9084b72c996759ed936016271c58370e37e5dc315eb9fe514102e

[root@pod19-srv2 ~]# docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS               NAMES
0c9ffe9225e9        alpine                           "/bin/sh"                13 seconds ago       Up 9 seconds                            pod19-srv1.ecatsrtpdmz.cisco.com/contiv-c2
e0d473622395        alpine                           "/bin/sh"                About a minute ago   Up About a minute                       pod19-srv2.ecatsrtpdmz.cisco.com/contiv-c1
36f04a36338c        alpine                           "/bin/sh"                4 minutes ago        Up 4 minutes                            pod19-srv2.ecatsrtpdmz.cisco.com/vanilla-c
7a4218de54c7        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   10 minutes ago       Up 10 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/auth-proxy
e7b6621a8257        quay.io/coreos/etcd:v2.3.8       "/etcd"                  12 minutes ago       Up 11 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/etcd
228913a30a93        quay.io/coreos/etcd:v2.3.8       "/etcd"                  12 minutes ago       Up 12 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/etcd

[root@pod19-srv2 ~]# docker exec -it contiv-c2 /bin/sh
/ # ping contiv-c1
PING contiv-c1 (30.1.2.1): 56 data bytes
64 bytes from 30.1.2.1: seq=0 ttl=64 time=1.899 ms
64 bytes from 30.1.2.1: seq=1 ttl=64 time=0.334 ms
64 bytes from 30.1.2.1: seq=2 ttl=64 time=0.481 ms
64 bytes from 30.1.2.1: seq=3 ttl=64 time=0.537 ms
^C
--- contiv-c1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.334/0.812/1.899 ms
/ # exit
```

As you will see during the ping that, built in dns resolves the name `contiv-c1`
to the IP address of `contiv-c1` container and be able to reach another container
across using a vxlan overlay.


#### Docker Overlay multi-host networking

Docker engine has a built in overlay driver that can be use to connect
containers across multiple nodes. However vxlan port used by `contiv`
driver is same as that of `overlay` driver from Docker.

### Chapter 3: Using multiple tenants with arbitrary IPs in the networks

Let's create a new tenant space.

```
[root@pod19-srv2 ~]# netctl tenant create blue
Creating tenant: blue
[root@pod19-srv2 ~]# netctl tenant ls 
Name     
------   
default  
blue

```

After the tenant is created, we can create network within in tenant `blue` and run containers.

```
[root@pod19-srv2 ~]# netctl net create -t blue --subnet=40.1.2.0/24 contiv-net 
Creating network blue:contiv-net
[root@pod19-srv2 ~]# netctl net ls -t blue
Tenant  Network     Nw Type  Encap type  Packet tag  Subnet       Gateway  IPv6Subnet  IPv6Gateway
------  -------     -------  ----------  ----------  -------      ------   ----------  -----------
blue    contiv-net  data     vxlan       0           40.1.2.0/24                       

```

Next, we can run containers belonging to this tenant

```
[root@pod19-srv2 ~]# docker run -itd --name=contiv-blue-c1 --net="contiv-net/blue" alpine /bin/sh
3b52a958a5ed15126bc064968a6157711677ee786c132e39ecbcf9e9854eb927
[root@pod19-srv2 ~]# docker ps 
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
3b52a958a5ed        alpine                           "/bin/sh"                7 seconds ago       Up 2 seconds                            pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c1
0c9ffe9225e9        alpine                           "/bin/sh"                4 minutes ago       Up 4 minutes                            pod19-srv1.ecatsrtpdmz.cisco.com/contiv-c2
e0d473622395        alpine                           "/bin/sh"                5 minutes ago       Up 5 minutes                            pod19-srv2.ecatsrtpdmz.cisco.com/contiv-c1
36f04a36338c        alpine                           "/bin/sh"                9 minutes ago       Up 8 minutes                            pod19-srv2.ecatsrtpdmz.cisco.com/vanilla-c
7a4218de54c7        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   14 minutes ago      Up 14 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/auth-proxy
e7b6621a8257        quay.io/coreos/etcd:v2.3.8       "/etcd"                  16 minutes ago      Up 16 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/etcd
228913a30a93        quay.io/coreos/etcd:v2.3.8       "/etcd"                  16 minutes ago      Up 16 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/etc

```

Let us run a couple of more containers in the host `pod19-srv1` that belong to the tenant `blue`:


```
[root@pod19-srv1 ~]# docker run -itd --name=contiv-blue-c2 --net="contiv-net/blue" alpine /bin/sh
f8718d13db4ff41c539cb64fa03ffa7c0408cae57a06ec67288faaab98637851
[root@pod19-srv1 ~]# docker run -itd --name=contiv-blue-c3 --net="contiv-net/blue" alpine /bin/sh
061b15039cc3e21358a32de4908d120ba21b5f6520846245ecfba7aa441a6d64
do^H^H[root@pod19-srv1 ~]# docker ps 
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS               NAMES
061b15039cc3        alpine                           "/bin/sh"                6 seconds ago        Up 2 seconds                            pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c3
f8718d13db4f        alpine                           "/bin/sh"                12 seconds ago       Up 8 seconds                            pod19-srv1.ecatsrtpdmz.cisco.com/contiv-blue-c2
3b52a958a5ed        alpine                           "/bin/sh"                About a minute ago   Up About a minute                       pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c1
0c9ffe9225e9        alpine                           "/bin/sh"                5 minutes ago        Up 5 minutes                            pod19-srv1.ecatsrtpdmz.cisco.com/contiv-c2
e0d473622395        alpine                           "/bin/sh"                6 minutes ago        Up 6 minutes                            pod19-srv2.ecatsrtpdmz.cisco.com/contiv-c1
36f04a36338c        alpine                           "/bin/sh"                10 minutes ago       Up 10 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/vanilla-c
7a4218de54c7        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   15 minutes ago       Up 15 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/auth-proxy
e7b6621a8257        quay.io/coreos/etcd:v2.3.8       "/etcd"                  17 minutes ago       Up 17 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/etcd
228913a30a93        quay.io/coreos/etcd:v2.3.8       "/etcd"                  17 minutes ago       Up 17 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/etcd

[root@pod19-srv1 ~]# docker network inspect contiv-net/blue
[
    {
        "Name": "contiv-net/blue",
        "Id": "3b592976dcaa376d83981be971c9840fa910cc3f768fdb6bb391a062bb025b8a",
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
                    "Subnet": "40.1.2.0/24"
                }
            ]
        },
        "Internal": false,
        "Containers": {
            "061b15039cc3e21358a32de4908d120ba21b5f6520846245ecfba7aa441a6d64": {
                "Name": "contiv-blue-c3",
                "EndpointID": "bd4a9047f15f2eb732a7efb28bf9a479da545530d39521b874ee100a3727c2e6",
                "MacAddress": "02:02:28:01:02:03",
                "IPv4Address": "40.1.2.3/24",
                "IPv6Address": ""
            },
            "3b52a958a5ed15126bc064968a6157711677ee786c132e39ecbcf9e9854eb927": {
                "Name": "contiv-blue-c1",
                "EndpointID": "54e2731506b622acbb340128ef06cd1417847c82c1636bec4eed5a8662bb924e",
                "MacAddress": "02:02:28:01:02:01",
                "IPv4Address": "40.1.2.1/24",
                "IPv6Address": ""
            },
            "f8718d13db4ff41c539cb64fa03ffa7c0408cae57a06ec67288faaab98637851": {
                "Name": "contiv-blue-c2",
                "EndpointID": "d93e4a1010f38fb83a857f5288a92bdfe0891dd87a47e2bad28ac901e2a6aba9",
                "MacAddress": "02:02:28:01:02:02",
                "IPv4Address": "40.1.2.2/24",
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

[root@pod19-srv1 ~]# docker exec -it contiv-blue-c3 /bin/sh
/ # ping contiv-blue-c1
PING contiv-blue-c1 (40.1.2.1): 56 data bytes
64 bytes from 40.1.2.1: seq=0 ttl=64 time=2.377 ms
64 bytes from 40.1.2.1: seq=1 ttl=64 time=0.078 ms
64 bytes from 40.1.2.1: seq=2 ttl=64 time=0.129 ms
^C
--- contiv-blue-c1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.078/0.861/2.377 ms
/ # ping contiv-blue-c2
PING contiv-blue-c2 (40.1.2.2): 56 data bytes
64 bytes from 40.1.2.2: seq=0 ttl=64 time=1.567 ms
64 bytes from 40.1.2.2: seq=1 ttl=64 time=0.314 ms
64 bytes from 40.1.2.2: seq=2 ttl=64 time=0.554 ms
^C
--- contiv-blue-c2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.314/0.811/1.567 ms

/ # exit
```

Scheduler schedules these containers using the scheduling algorithm `bin-packing` or `spread`, and if they are not placed on different nodes, feel free to start more containers to see the distribution.


## Contiv Policy Features


### Chapter 4 - ICMP Policy

In this section, we will create two groups epgA and epgB. We will create container with respect to those groups. 
Then by default communication between group is allowed. So we will have ICMP deny policy and verify that we are not able to ping among those containers.

Let us create Tenant and Network first.

```
[root@pod19-srv1 ~]# netctl tenant create TestTenant
Creating tenant: TestTenant

[root@pod19-srv1 ~]# netctl network create --tenant TestTenant --subnet=20.1.1.0/24 --gateway=20.1.1.254 TestNet
netctl net ls -aCreating network TestTenant:TestNet

[root@pod19-srv1 ~]# netctl net ls -a
Tenant      Network     Nw Type  Encap type  Packet tag  Subnet       Gateway     IPv6Subnet  IPv6Gateway
------      -------     -------  ----------  ----------  -------      ------      ----------  -----------
default     contiv-net  data     vxlan       0           30.1.2.0/24                          
blue        contiv-net  data     vxlan       0           40.1.2.0/24                          
TestTenant  TestNet     data     vxlan       0           20.1.1.0/24  20.1.1.254 

```

Now, create two groups epgA and epgB, under network TestNet.


```
[root@pod19-srv1 ~]# netctl group create -t TestTenant TestNet epgA
Creating EndpointGroup TestTenant:epgA

[root@pod19-srv1 ~]# netctl group create -t TestTenant TestNet epgB
Creating EndpointGroup TestTenant:epgB

[root@pod19-srv1 ~]# netctl group ls -a
Tenant      Group  Network  IP Pool   Policies  Network profile
------      -----  -------  --------  ---------------
TestTenant  epgA   TestNet              
TestTenant  epgB   TestNet        

```

Now you will see thse groups and networks are reported as network to docker-engine, with driver listed as netplugin.


```
[root@pod19-srv1 ~]# docker network ls
NETWORK ID          NAME                                               DRIVER              SCOPE
def827390629        TestNet/TestTenant                                 netplugin           global              
d120aeb0010b        contiv-net                                         netplugin           global              
3b592976dcaa        contiv-net/blue                                    netplugin           global              
d2b9e4042eb5        epgA/TestTenant                                    netplugin           global              
fd2ab7b581dd        epgB/TestTenant                                    netplugin           global              
4c7a511c1131        pod19-srv1.ecatsrtpdmz.cisco.com/bridge            bridge              local               
a0938130151d        pod19-srv1.ecatsrtpdmz.cisco.com/docker_gwbridge   bridge              local               
e8be04ef7ab7        pod19-srv1.ecatsrtpdmz.cisco.com/host              host                local               
632ec424d389        pod19-srv1.ecatsrtpdmz.cisco.com/none              null                local               
ffa83d536aba        pod19-srv2.ecatsrtpdmz.cisco.com/bridge            bridge              local               
f3f357171048        pod19-srv2.ecatsrtpdmz.cisco.com/docker_gwbridge   bridge              local               
43f4fb17d806        pod19-srv2.ecatsrtpdmz.cisco.com/host              host                local               
dce44a32c67d        pod19-srv2.ecatsrtpdmz.cisco.com/none              null                local               
[root@pod19-srv1 ~]# 

```

Let us create two containers on each group network and check whether they are able to ping each other or not.
By default, Contiv allows connectivity between groups under same network.


```
[root@pod19-srv1 ~]# docker run -itd --net="epgA/TestTenant" --name=AContainer contiv/alpine sh
3933c859740e534ed42ba4277ab3291b56d24d70ffcdb454707413a1308bac43

[root@pod19-srv1 ~]# docker run -itd --net="epgB/TestTenant" --name=BContainer contiv/alpine sh
505d20ea5b85f157a4eb10855e762b68b4ee04291c8d4b3e7ec2c587eeaacc35

[root@pod19-srv1 ~]# docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS                  PORTS               NAMES
505d20ea5b85        contiv/alpine                    "sh"                     3 seconds ago       Up Less than a second                       pod19-srv1.ecatsrtpdmz.cisco.com/BContainer
3933c859740e        contiv/alpine                    "sh"                     14 seconds ago      Up 10 seconds                               pod19-srv2.ecatsrtpdmz.cisco.com/AContainer
061b15039cc3        alpine                           "/bin/sh"                14 minutes ago      Up 14 minutes                               pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c3
f8718d13db4f        alpine                           "/bin/sh"                14 minutes ago      Up 14 minutes                               pod19-srv1.ecatsrtpdmz.cisco.com/contiv-blue-c2
3b52a958a5ed        alpine                           "/bin/sh"                15 minutes ago      Up 15 minutes                               pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c1
0c9ffe9225e9        alpine                           "/bin/sh"                20 minutes ago      Up 20 minutes                               pod19-srv1.ecatsrtpdmz.cisco.com/contiv-c2
e0d473622395        alpine                           "/bin/sh"                21 minutes ago      Up 20 minutes                               pod19-srv2.ecatsrtpdmz.cisco.com/contiv-c1
36f04a36338c        alpine                           "/bin/sh"                24 minutes ago      Up 24 minutes                               pod19-srv2.ecatsrtpdmz.cisco.com/vanilla-c
7a4218de54c7        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   30 minutes ago      Up 30 minutes                               pod19-srv1.ecatsrtpdmz.cisco.com/auth-proxy
e7b6621a8257        quay.io/coreos/etcd:v2.3.8       "/etcd"                  31 minutes ago      Up 31 minutes                               pod19-srv2.ecatsrtpdmz.cisco.com/etcd
228913a30a93        quay.io/coreos/etcd:v2.3.8       "/etcd"                  32 minutes ago      Up 32 minutes                               pod19-srv1.ecatsrtpdmz.cisco.com/etcd

```

Now try to ping from AContainer to BContainer. They should be able to ping each other.

```
To find IP address or AContainer:
[root@pod19-srv1 ~]# docker exec -it AContainer sh 
/ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:02:14:01:01:01  
          inet addr:20.1.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:14ff:fe01:101%32529/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:20 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1632 (1.5 KiB)  TX bytes:984 (984.0 B)
/ # exit

Now ping AContainer from BContainer

[root@pod19-srv1 ~]# docker exec -it BContainer sh
/ # ping 20.1.1.1 
PING 20.1.1.1 (20.1.1.1) 56(84) bytes of data.
64 bytes from 20.1.1.1: icmp_seq=1 ttl=64 time=1.73 ms
64 bytes from 20.1.1.1: icmp_seq=2 ttl=64 time=0.231 ms
64 bytes from 20.1.1.1: icmp_seq=3 ttl=64 time=0.168 ms
^C
--- 20.1.1.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.168/0.712/1.738/0.726 ms

/ # exit

```

Now add ICMP Deny policy. Container should not be able to ping each other now.

Adding policy and modifying group.

```

[root@pod19-srv1 ~]# netctl policy create -t TestTenant policyAB
Creating policy TestTenant:policyAB

[root@pod19-srv1 ~]# netctl policy rule-add -t TestTenant -d in --protocol icmp  --from-group epgA  --action deny policyAB 1

[root@pod19-srv1 ~]# netctl group create -t TestTenant -p policyAB TestNet epgB
Creating EndpointGroup TestTenant:epgB

[root@pod19-srv1 ~]# netctl policy ls -a
Tenant      Policy
------      ------
TestTenant  policyAB

[root@pod19-srv1 ~]# netctl policy rule-ls -t TestTenant policyAB
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
[root@pod19-srv1 ~]# docker exec -it BContainer sh
/ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:02:14:01:01:02  
          inet addr:20.1.1.2  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:14ff:fe01:102%32521/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:984 (984.0 B)  TX bytes:984 (984.0 B)

/ # ping 20.1.1.1
PING 20.1.1.1 (20.1.1.1) 56(84) bytes of data.
^C
--- 20.1.1.1 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4000ms

/ # exit

```

### Chapter 5 - TCP Policy

In this section, We will add TCP 8001 port deny policy and then will verify this policy.

Creating TCP port policy.

```

[root@pod19-srv1 ~]# netctl policy rule-add -t TestTenant -d in --protocol tcp --port 8001  --from-group epgA  --action deny policyAB 2

[root@pod19-srv1 ~]# netctl policy rule-ls -t TestTenant policyAB
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1         epgA                                              icmp      0     deny
2     1         epgA                                              tcp       8001  deny
Outgoing Rules:
Rule  Priority  To EndpointGroup  To Network  To IpAddress  Protocol  Port  Action
----  --------  ----------------  ----------  ---------     --------  ----  ------


```

Now check that from app group, TCP 8001 port is denied. To test this, Let us run iperf on BContainer and
verify using nc utility on AContainer.


```
On BContainer:

[root@pod19-srv1 ~]# docker exec -it BContainer sh
/ # iperf -s -p 8001
------------------------------------------------------------
Server listening on TCP port 8001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------



On AContainer:

[root@pod19-srv2 ~]# docker exec -it AContainer sh
/ #  nc -zvw 1 20.1.1.2 8001 --------> here 20.1.1.2 
is IP address of BContainer
nc: 20.1.1.2 (20.1.1.2:8001): Operation timed out

You see that the connection to port 8001 is denied.

```

Now, let us ensure that the other ports (e.g. 8000) are open (allowed). 

```
On BContainer:

[root@pod19-srv1 ~]# docker exec -it BContainer sh
/ # iperf -s -p 8000
------------------------------------------------------------
Server listening on TCP port 8000
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 20.1.1.2 port 8000 connected with 20.1.1.1 port 43013
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 0.0 sec  0.00 Bytes  0.00 bits/sec



On AContainer:

[root@pod19-srv2 ~]# docker exec -it AContainer sh
/ #  nc -zvw 1 20.1.1.2 8000 --------> here 20.1.1.2 
is IP address of BContainer
20.1.1.2 (20.1.1.2:8000) open 


You see that the connection to port 8000 is allowed.

```


### Chapter 6 - Bandwidth Policy

In this chapter, we will explore bandwidth policy feature of contiv. 
We will create tenant, network and groups. Then we will attach netprofile to one group
and verify that applied bandwidth is working or not as expected in data path.


So, let us create tenant, a network and group "A" under network.


```
[root@pod19-srv2 ~]# netctl tenant create BandwidthTenant
Creating tenant: BandwidthTenant

[root@pod19-srv2 ~]# netctl network create --tenant BandwidthTenant --subnet=50.1.1.0/24 --gateway=50.1.1.254 BandwidthTestNet
Creating network BandwidthTenant:BandwidthTestNet

[root@pod19-srv2 ~]# netctl group create -t BandwidthTenant BandwidthTestNet epgA
Creating EndpointGroup BandwidthTenant:epgA

[root@pod19-srv2 ~]# netctl net ls -a 
Tenant           Network           Nw Type  Encap type  Packet tag  Subnet       Gateway     IPv6Subnet  IPv6Gateway
------           -------           -------  ----------  ----------  -------      ------      ----------  -----------
BandwidthTenant  BandwidthTestNet  data     vxlan       0           50.1.1.0/24  50.1.1.254              
default          contiv-net        data     vxlan       0           30.1.2.0/24                          
blue             contiv-net        data     vxlan       0           40.1.2.0/24                          
TestTenant       TestNet           data     vxlan       0           20.1.1.0/24  20.1.1.254    

```

Now, We are going to run serverA and clientA containers using group epgA as a network.


```

[root@pod19-srv2 ~]# docker run -itd --net="epgA/BandwidthTenant" --name=serverA contiv/alpine sh
9552047f339bf37edce1e92f79143b26f47b0d3cd9146e4946d3152701dd0252

[root@pod19-srv2 ~]# docker run -itd --net="epgA/BandwidthTenant" --name=clientA contiv/alpine sh
36a1d8554187e033ff843382eea86a1c39fd8e2064fee01f712267b158664208

[root@pod19-srv2 ~]# docker ps 
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
36a1d8554187        contiv/alpine                    "sh"                     36 seconds ago      Up 33 seconds                           pod19-srv2.ecatsrtpdmz.cisco.com/clientA
9552047f339b        contiv/alpine                    "sh"                     47 seconds ago      Up 44 seconds                           pod19-srv1.ecatsrtpdmz.cisco.com/serverA
505d20ea5b85        contiv/alpine                    "sh"                     16 minutes ago      Up 16 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/BContainer
3933c859740e        contiv/alpine                    "sh"                     16 minutes ago      Up 16 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/AContainer
061b15039cc3        alpine                           "/bin/sh"                31 minutes ago      Up 31 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c3
f8718d13db4f        alpine                           "/bin/sh"                31 minutes ago      Up 31 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/contiv-blue-c2
3b52a958a5ed        alpine                           "/bin/sh"                32 minutes ago      Up 32 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c1
0c9ffe9225e9        alpine                           "/bin/sh"                36 minutes ago      Up 36 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/contiv-c2
e0d473622395        alpine                           "/bin/sh"                37 minutes ago      Up 37 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/contiv-c1
36f04a36338c        alpine                           "/bin/sh"                41 minutes ago      Up 41 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/vanilla-c
7a4218de54c7        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   46 minutes ago      Up 46 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/auth-proxy
e7b6621a8257        quay.io/coreos/etcd:v2.3.8       "/etcd"                  48 minutes ago      Up 48 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/etcd
228913a30a93        quay.io/coreos/etcd:v2.3.8       "/etcd"                  48 minutes ago      Up 48 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/etcd

```

Now run iperf server and client to find out current bandwidth which we are getting on the network
where you are running this tutorial. It may vary depending upon base OS, network speed etc.


```
On serverA:

[root@pod19-srv2 ~]# docker exec -it serverA sh
/ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:02:32:01:01:01  
          inet addr:50.1.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:32ff:fe01:101%32725/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

/ # iperf -s -u 
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.1 port 5001 connected with 50.1.1.2 port 56821
[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec   0.082 ms    0/  893 (0%)
^C/ # exit


On clientA:

[root@pod19-srv1 ~]# docker exec -it clientA sh
/ # iperf -c 50.1.1.1 -u
------------------------------------------------------------
Client connecting to 50.1.1.1, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.2 port 56821 connected with 50.1.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec
[  3] Sent 893 datagrams
[  3] Server Report:
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec   0.082 ms    0/  893 (0%)
/ # exit

```

Now we see that, current bandwidth we are getting is 1.05 Mbits/sec.
So let us create new group B and create netprofile with bandwidth less than the one 
we got above. So let us create netprofile with bandwidth of 500Kbits/sec.

```

[root@pod19-srv2 ~]# netctl netprofile create -t BandwidthTenant -b 500Kbps -d 6 -s 80 testProfile
Creating netprofile BandwidthTenant:testProfile

[root@pod19-srv2 ~]# netctl group create -t BandwidthTenant -n testProfile BandwidthTestNet epgB
Creating EndpointGroup BandwidthTenant:epgB

[root@pod19-srv2 ~]# netctl netprofile ls -a
Name         Tenant           Bandwidth  DSCP      burst size
------       ------           ---------  --------  ----------
testProfile  BandwidthTenant  500Kbps    6         80

[root@pod19-srv2 ~]# netctl group ls -a
Tenant           Group  Network           IP Pool   Policies  Network profile
------           -----  -------           --------  ---------------
TestTenant       epgA   TestNet                               
TestTenant       epgB   TestNet                     policyAB  
BandwidthTenant  epgA   BandwidthTestNet                      
BandwidthTenant  epgB   BandwidthTestNet                      testProfile
[root@pod19-srv2 ~]# 

```

Running clientB and serverB containers:

```

[root@pod19-srv2 ~]# docker run -itd --net="epgB/BandwidthTenant" --name=serverB contiv/alpine sh
7f840198595e800a1a1005eb1699fa39d4240a93ca44f37a3c9fb04a6655436e

[root@pod19-srv2 ~]# docker run -itd --net="epgB/BandwidthTenant" --name=clientB contiv/alpine sh
8dabce8d9e24a369de4d260d223f403ea419719d9e6f4309640373bef0e49706

[root@pod19-srv2 ~]# docker ps 
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
8dabce8d9e24        contiv/alpine                    "sh"                     5 seconds ago       Up 1 seconds                            pod19-srv2.ecatsrtpdmz.cisco.com/clientB
7f840198595e        contiv/alpine                    "sh"                     12 seconds ago      Up 8 seconds                            pod19-srv1.ecatsrtpdmz.cisco.com/serverB
36a1d8554187        contiv/alpine                    "sh"                     17 minutes ago      Up 17 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/clientA
9552047f339b        contiv/alpine                    "sh"                     17 minutes ago      Up 17 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/serverA
505d20ea5b85        contiv/alpine                    "sh"                     33 minutes ago      Up 33 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/BContainer
3933c859740e        contiv/alpine                    "sh"                     33 minutes ago      Up 33 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/AContainer
061b15039cc3        alpine                           "/bin/sh"                47 minutes ago      Up 47 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c3
f8718d13db4f        alpine                           "/bin/sh"                48 minutes ago      Up 47 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/contiv-blue-c2
3b52a958a5ed        alpine                           "/bin/sh"                49 minutes ago      Up 48 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/contiv-blue-c1
0c9ffe9225e9        alpine                           "/bin/sh"                53 minutes ago      Up 53 minutes                           pod19-srv1.ecatsrtpdmz.cisco.com/contiv-c2
e0d473622395        alpine                           "/bin/sh"                54 minutes ago      Up 54 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/contiv-c1
36f04a36338c        alpine                           "/bin/sh"                57 minutes ago      Up 57 minutes                           pod19-srv2.ecatsrtpdmz.cisco.com/vanilla-c
7a4218de54c7        contiv/auth_proxy:1.0.0-beta.6   "./auth_proxy --tls-k"   About an hour ago   Up About an hour                        pod19-srv1.ecatsrtpdmz.cisco.com/auth-proxy
e7b6621a8257        quay.io/coreos/etcd:v2.3.8       "/etcd"                  About an hour ago   Up About an hour                        pod19-srv2.ecatsrtpdmz.cisco.com/etcd
228913a30a93        quay.io/coreos/etcd:v2.3.8       "/etcd"                  About an hour ago   Up About an hour                        pod19-srv1.ecatsrtpdmz.cisco.com/etcd
```

Now as we are running clientB and serverB containers on group B network. we should see bandwidth around
500Kbps. Thats the verification that our bandwidth netprofile is working as per expectation.

```

On serverB:

[root@pod19-srv1 ~]# docker exec -it serverB sh
/ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:02:32:01:01:03  
          inet addr:50.1.1.3  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:32ff:fe01:103%32745/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:16 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1296 (1.2 KiB)  TX bytes:648 (648.0 B)

/ # iperf -s -u 
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.3 port 5001 connected with 50.1.1.4 port 36954
[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-10.3 sec   692 KBytes   552 Kbits/sec  15.732 ms  411/  893 (46%)


On clientB:

[root@pod19-srv2 ~]# docker exec -it clientB sh
/ # iperf -c 50.1.1.3 -u 
------------------------------------------------------------
Client connecting to 50.1.1.3, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.4 port 36954 connected with 50.1.1.3 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec
[  3] Sent 893 datagrams
[  3] Server Report:
[  3]  0.0-10.3 sec   692 KBytes   552 Kbits/sec  15.732 ms  411/  893 (46%)
/ # exit

As we see, clientB is getting roughly around 500Kbps bandwidth.

```
