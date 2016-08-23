---
layout: "documents"
page_title: "Kubernetes cluster"
sidebar_current: "getting-started-networking-vagrant-k8s"
description: |-
  Setting up Kubernetes cluster
---

# Contiv Networking with Kubernetes

Contiv integrates with Kubernetes using a common network interface (CNI) plugin. 
With this integration, Contiv Networking and Policy can be used for pod interconnectivity 
in a Kubernetes cluster.

This page guides you through creating a minimal Kubernetes 
cluster with Contiv networking and applying policy between pods.

## Prerequisites

1\. Install the following packages on your Linux or OS X machine:

- VirtualBox 5.0.2 or later
- Vagrant 1.7.4
- make, git and bzip2

2\. Set http/https proxies if your network requires it.
*Note*: Set `https_proxy` to point to an `http://`
 URL (not `https://`). This is an ansible requirement.

3\. The setup scripts use the Python modules *parse* and *netaddr*. If these modules are not
installed on the machine where you are executing these steps, install them
before proceeding. (Use `pip install parse; pip install netaddr`.)

### Step 1: Clone the Repositories
Use the following commands to clone the Contiv Network and contributed
project repositories to your local machine:

```
$ mkdir -p ~/go/src/github.com/k8s
$ cd ~/go/src/github.com/k8s
$ git clone https://github.com/jojimt/contrib -b contiv

$ cd ~/go/src/github.com/k8s
$ git clone https://github.com/contiv/netplugin
```

### Step 2: Create a Vagrant Environment
The following commands run Vagrant and Ansible commands to start a 
Kubernetes cluster with one master and two worker nodes. This process
can take a few minutes.

Navigate to the `netplugin` directory and run the *k8s-cluster*
make target:

```
$ cd ~/go/src/github.com/k8s/netplugin
$ make k8s-cluster
```

When the process is complete, a message like the following displays:

```
PLAY RECAP ********************************************************************
k8master                   : ok=xxx  changed=xxx  unreachable=0    failed=0   
k8node-01                  : ok=xxx  changed=xxx  unreachable=0    failed=0   
k8node-02                  : ok=xxx  changed=xxx  unreachable=0    failed=0   
```

At this point, your cluster is ready to use.

*Note*: Occasionally, you might encounter an error during Ansible provisioning.
If this happens, just re-issue the command (usually, it's caused by a temporary
unavailability of a repository on the web). If the problem persists, open an
issue on GitHub.

You should proceed to Step 3 *only* if the previous step completed successfully.

This demo uses a *busybox* image built to include a full *netcat* utility.
However, you can try other images as well if you like. *The Dockerfile used to
build the nc-busybox is available in the `/shared` folder of the *k8master* node
See Step 3).

#### Step 3: Start the Network Services
The following command starts network services and logs you into the kubernetes master node.

```
$ make k8s-demo-start
```

When this process is finished, you are shown a shell prompt on the master node.
Use `sudo su` to enter *sudo* mode and try a few commands as follows:

```
[vagrant@k8master ~]$ sudo su
[root@k8master vagrant]# kubectl get nodes
NAME        LABELS                             STATUS    AGE
k8node-01   kubernetes.io/hostname=k8node-01   Ready     4m
k8node-02   kubernetes.io/hostname=k8node-02   Ready     4m

[root@k8master vagrant]# netctl net list
Tenant   Network      Encap type  Packet tag  Subnet       Gateway
------   -------      ----------  ----------  -------      ------
default  default-net  vxlan       <nil>       20.1.1.0/24  20.1.1.254
default  poc-net      vxlan       <nil>       21.1.1.0/24  21.1.1.254

[root@k8master ~]# netctl group list
Tenant   Group        Network      Policies
------   -----        -------      --------
default  default-epg  default-net  
default  poc-epg      poc-net

```

The last two commands show Contiv configuration. The demo setup created two networks
and two endpoint groups (EPGs).

The demo environment is now ready. Following are some examples of creating some clustered
containers.

## Example 1: No Network Labels 
With no network labels, the pod is placed in a default network.

Navigate to the `/shared` directory to find some pod specification files. Use the files to
create `defaultnet-busybox1` and `defaultnet-busybox2`:

```
[root@k8master ~]# cd /shared
[root@k8master shared]#ls
defaultnet-busybox1.yaml  noping-busybox.yaml  pocnet-busybox.yaml
defaultnet-busybox2.yaml  pingme-busybox.yaml  policy.sh

[root@k8master shared]# kubectl create -f defaultnet-busybox1.yaml
pod "defaultnet-busybox1" created
[root@k8master shared]# kubectl create -f defaultnet-busybox2.yaml
pod "defaultnet-busybox2" created

[root@k8master shared]# kubectl get pods
NAME                 READY     STATUS    RESTARTS   AGE
defaultnet-busybox1  1/1       Running   0          3m
defaultnet-busybox2  1/1       Running   0          39s

```

It may take a few minutes for the pods to enter the *Running* state. 
When both have entered the `Running` state, verify their IP addresses and reachability:

```
[root@k8master shared]# kubectl exec defaultnet-busybox1 -- ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
47: eth0@if46: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue
    link/ether 02:02:14:01:01:09 brd ff:ff:ff:ff:ff:ff
    inet 20.1.1.9/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::2:14ff:fe01:109/64 scope link
       valid_lft forever preferred_lft forever


[root@k8master shared]# kubectl describe pod defaultnet-busybox2 | grep IP
IP:                             20.1.1.10

[root@k8master shared]# kubectl exec defaultnet-busybox1 -- ping 20.1.1.10
PING 20.1.1.10 (20.1.1.10): 56 data bytes
64 bytes from 20.1.1.10: seq=0 ttl=64 time=0.562 ms
64 bytes from 20.1.1.10: seq=1 ttl=64 time=0.124 ms
64 bytes from 20.1.1.10: seq=2 ttl=64 time=0.073 ms

```

Notice that both pods were assigned IP addresses from the default network and
that they can ping each other.

## Example 2: Labeled Network
In this examply you use network labels to specify a network and EPG for the Pod.

Type the following command to create a Pod with `poc-net` and `poc-epg` specified as the 
network and EPG respectively:

```
[root@k8master shared]# kubectl create -f pocnet-busybox.yaml
pod "busybox-poc-net" created
```


Examine `pocnet-busybox.yaml`. There are two additional labels,
`io.contiv.network: poc-net` and `io.contiv.net-group: poc-epg`, defined
in this pod specification.

Notice that this pod was assigned an IP addresses from the poc-net:

```
[root@k8master shared]# kubectl get pods
NAME                  READY     STATUS    RESTARTS   AGE
busybox-poc-net       1/1       Running   0          54s
defaultnet-busybox1   1/1       Running   0          35m
defaultnet-busybox2   1/1       Running   0          35m

[root@k8master shared]# kubectl exec busybox-poc-net -- ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
129: eth0@if128: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue
    link/ether 02:02:15:01:01:02 brd ff:ff:ff:ff:ff:ff
    inet 21.1.1.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::2:15ff:fe01:102/64 scope link
       valid_lft forever preferred_lft forever
```

## Example 3: Use Contiv to Specify and Enforce Network Policy

In this example, you create a policy and attach it to an EPG. You specify
this epg in the pod specification and verify that the policy is enforced.

Examine `policy.sh`. This file contains Contiv commands to create a simple 
ICMP deny rule, add the rule to a policy, and attach the policy to an EPG. 

Excute this script to create the network objects:

```
[root@k8master shared]# ./policy.sh

[root@k8master shared]# netctl group list
Tenant   Group        Network      Policies
------   -----        -------      --------
default  poc-epg      poc-net      
default  noping-epg   poc-net      icmpPol
default  default-epg  default-net  

[root@k8master shared]# netctl rule list icmpPol
Rule  Direction  Priority  EndpointGroup  Network  IpAddress  Protocol  Port   Action
----  ---------  --------  -------------  -------  ---------  --------  ----   ------
1     in         1         <nil>          <nil>    <nil>      icmp      <nil>  deny

```

Examine `noping-busybox.yaml` and `pingme-busybox.yaml`. They specify `noping-epg` and `poc-epg`
respectively as their EPGs. Both of these pods have a *netcat* listener on TCP port 6379
(See `nc-busybox/nc_loop.sh`).

Create both of these pods and verify their connectivity behavior.

```
[root@k8master shared]# kubectl create -f noping-busybox.yaml
pod "annoyed-busybox" created
[root@k8master shared]# kubectl create -f pingme-busybox.yaml
pod "sportive-busybox" created

[root@k8master shared]# kubectl get pods
NAME                READY     STATUS    RESTARTS   AGE
annoyed-busybox       1/1       Running   0          22m
busybox-poc-net       1/1       Running   0          35m
defaultnet-busybox1   1/1       Running   0          35m
defaultnet-busybox2   1/1       Running   0          35m
sportive-busybox      1/1       Running   0          21m


[root@k8master shared]# kubectl describe pod annoyed-busybox | grep IP
IP:                             21.1.1.2

[root@k8master shared]# kubectl describe pod sportive-busybox | grep IP
IP:                             21.1.1.4

```

Try to access `annoyed-busybox` and `sportive-busybox` from `busybox-poc-net` 
using *ping* and *nc*:

```
[root@k8master shared]# kubectl exec busybox-poc-net -- ping 21.1.1.2

[root@k8master shared]# kubectl exec busybox-poc-net -- ping 21.1.1.4
PING 21.1.1.4 (21.1.1.4): 56 data bytes
64 bytes from 21.1.1.4: seq=0 ttl=64 time=0.230 ms
64 bytes from 21.1.1.4: seq=1 ttl=64 time=0.390 ms
64 bytes from 21.1.1.4: seq=2 ttl=64 time=0.205 ms

[root@k8master shared]# kubectl exec busybox-poc-net -- nc -zvw 1 21.1.1.2 6379
21.1.1.2 [21.1.1.2] 6379 (6379) open

[root@k8master shared]# kubectl exec busybox-poc-net -- nc -zvw 1 21.1.1.4 6379
21.1.1.4 [21.1.1.4] 6379 (6379) open

```

Notice that: 
1. `busybox-poc-net` is unable to ping `annoyed-busybox`
2. `busybox-poc-net` is able to ping `sportive-busybox`, 
to which no policy was applied. 
3. `busybox-poc-net` is able to exchange TCP with `annoyed-busybox`, 
consistent with the applied policy. You can try other combinations as 
well, for example applying  ping and nc between `annoyed-busybox` and `sportive-busybox`.
You can also create your own policy and pod spec and try.
