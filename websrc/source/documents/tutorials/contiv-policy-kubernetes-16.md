---
layout: "documents"
page_title: "Contiv Policy Networking Tutorial (Kubernetes 1.6)"
sidebar_current: "contiv-policy"
description: |-
  Contiv Policy Networking Tutorial (Kubernetes 1.6)
---

## Contiv Policy Tutorial with Kubernetes

This tutorial walks through advanced features of Contiv container networking.

### Setup
Follow all steps from the [Container Networking Tutorial](/documents/tutorials/networking-kubernetes-16.html).

###Chapter 1 - ICMP Policy

In this section, we will create two groups epgA and epgB. We will create containers with respect to those groups. Then, by default, communication between the groups is allowed. So, we will create an ICMP deny policy and verify that we are not able to ping between those containers.

Let's create a Tenant and Network first.

```
[vagrant@kubeadm-master ~]$ netctl tenant create TestTenant
Creating tenant: TestTenant 
```
Create a network under this tenant.

```
[vagrant@kubeadm-master ~]$ netctl network create --tenant TestTenant --subnet=10.1.1.0/24 --gateway=10.1.1.254 -e "vlan" TestNet
Creating network TestTenant:TestNet
```
We can see the networks that are present within the cluster.

```
[vagrant@kubeadm-master ~]$ netctl net ls -a
Tenant      Network      Nw Type  Encap type  Packet tag  Subnet        Gateway     IPv6Subnet  IPv6Gateway  Cfgd Tag
------      -------      -------  ----------  ----------  -------       ------      ----------  -----------  ---------
default     contivh1     infra    vxlan       0           132.1.1.0/24  132.1.1.1
default     default-net  data     vxlan       0           20.1.1.0/24   20.1.1.1
TestTenant  TestNet      data     vlan        0           10.1.1.0/24   10.1.1.254
```
Now create two network groups under network TestNet.

```
[vagrant@kubeadm-master ~]$ netctl group create -t TestTenant TestNet epgA
Creating EndpointGroup TestTenant:epgA 

[vagrant@kubeadm-master ~]$ netctl group create -t TestTenant TestNet epgB
Creating EndpointGroup TestTenant:epgB 
```
We can list the network groups as well.

```
[vagrant@kubeadm-master ~]$ netctl group ls -a
Tenant      Group  Network  IP Pool  CfgdTag  Policies  Network profile
------      -----  -------  -------  -------  --------  ---------------
TestTenant  epgA   TestNet
TestTenant  epgB   TestNet
```
Let's create two pods, one on each group network, and check whethere they are able to ping each other or not. By default, Contiv allows connectivity between groups under the same network.

```
[vagrant@contiv-node1 ~]$ 
cat <<EOF > apod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: apod
  labels:
    app: apod
    io.contiv.tenant: TestTenant
    io.contiv.net-group: epgA
    io.contiv.network: TestNet
spec:
  containers:
  - name: alpine
    image: alpine
    command:
      - sleep
      - "6000"
EOF
 
[vagrant@kubeadm-master ~]$ kubectl create -f apod.yaml
pod "apod" created
```
```
[vagrant@contiv-node1 ~]$ 
cat <<EOF > bpod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: bpod
  labels:
    app: bpod
    io.contiv.tenant: TestTenant
    io.contiv.net-group: epgB
    io.contiv.network: TestNet
spec:
  containers:
  - name: alpine
    image: alpine
    command:
      - sleep
      - "6000"
EOF
 
[vagrant@kubeadm-master ~]$ kubectl create -f bpod.yaml
pod "bpod" created
```
Let's make sure our pods are up and running.

```
[vagrant@kubeadm-master ~]$ kubectl get pods -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP         NODE
apod      1/1       Running   0          1m        10.1.1.1   kubeadm-worker0
bpod      1/1       Running   0          1m        10.1.1.2   kubeadm-worker0
```
Now try to ping from apod to bpod. They should be able to ping each other.

```
[vagrant@kubeadm-master ~]$ kubectl exec -it bpod sh
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
[vagrant@kubeadm-master ~]$ kubectl exec -it apod sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:0A:01:01:01
          inet addr:10.1.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:aff:fe01:101/64 Scope:Link
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

/ # ping -c 3 10.1.1.2
PING 10.1.1.2 (10.1.1.2): 56 data bytes
64 bytes from 10.1.1.2: seq=0 ttl=64 time=46.369 ms
64 bytes from 10.1.1.2: seq=1 ttl=64 time=0.085 ms
64 bytes from 10.1.1.2: seq=2 ttl=64 time=0.076 ms

--- 10.1.1.2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.076/15.510/46.369 ms
/ # exit
```
Now let’s add an ICMP Deny policy and modify group epgB. The pods should not be able to ping each other now.

Create the policy.

```
[vagrant@kubeadm-master ~]$ netctl policy create -t TestTenant policyAB
Creating policy TestTenant:policyAB 
```
Add a rule to the policy.

```
[vagrant@kubeadm-master ~]$ netctl policy rule-add -t TestTenant -d in --protocol icmp --from-group epgA --action deny policyAB 1
```
Create a group associated with this policy.

```
[vagrant@kubeadm-master ~]$ netctl group create -t TestTenant -p policyAB TestNet epgB
Creating EndpointGroup TestTenant:epgB 
```
```
[vagrant@kubeadm-master ~]$ netctl policy ls -a
Tenant      Policy
------      ------
TestTenant  policyAB
 
[vagrant@kubeadm-master ~]$ netctl policy rule-ls -t TestTenant policyAB
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1         epgA                                              icmp      0     deny
Outgoing Rules:
Rule  Priority  To EndpointGroup  To Network  To IpAddress  Protocol  Port  Action
----  --------  ----------------  ----------  ---------     --------  ----  ------
```

Now ping between pods should not work.

```
[vagrant@kubeadm-master ~]$ kubectl exec -it apod sh
/ # ping -c 3 10.1.1.2
PING 10.1.1.2 (10.1.1.2): 56 data bytes

--- 10.1.1.2 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss
/ # exit
```

### Cleanup: **after all play is done**
To cleanup the setup, after doing all the experiments, exit the VM destroy VMs:

```
[vagrant@kubeadm-master ~]$ exit

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
