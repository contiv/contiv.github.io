---
layout: "documents"
page_title: "Contiv Policy Networking Tutorial (Kubernetes 1.6)"
sidebar_current: "contiv-policy"
description: |-
  Contiv Policy Networking Tutorial (Kubernetes 1.6)
---




## Contiv Policy Tutorial with Kubernetes

 - [Setup](#setup)
 - [Chapter 1 - ICMP Policy](#ch1)
 - [Chapter 2 - TCP Policy](#ch2)
 - [Chapter 3 - Bandwidth Policy](#ch3)
 - [Cleanup](#cleanup)

This tutorial walks through advanced features of Contiv container networking.

### <a name="setup"></a> Setup
Follow all steps from the [Container Networking Tutorial](/documents/tutorials/networking-kubernetes-16.html).

### <a name="ch1"></a> Chapter 1 - ICMP Policy

In this section, we will create two groups epgA and epgB. We will create containers with respect to those groups. Then, by default, communication between the groups is allowed. So, we will create an ICMP deny policy and verify that we are not able to ping between those containers.

Let's create a tenant and network first.

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
default     default-net  data     vxlan       0           20.1.1.0/24   20.1.1.1
...
TestTenant  TestNet      data     vlan        0           10.1.1.0/24   10.1.1.254
default     contivh1     infra    vxlan       0           132.1.1.0/24  132.1.1.1
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
Let's create two pods, one on each group network, and check whether they are able to ping each other or not. By default, Contiv allows connectivity between groups under the same network.

```
[vagrant@kubeadm-master ~]$ cat <<EOF > apod.yaml
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
    image: contiv/alpine
    command:
      - sleep
      - "6000"
EOF
 
[vagrant@kubeadm-master ~]$ kubectl create -f apod.yaml
pod "apod" created
```
```
[vagrant@kubeadm-master ~]$ cat <<EOF > bpod.yaml
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
    image: contiv/alpine
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
NAME                        READY     STATUS    RESTARTS   AGE       IP         NODE
apod                        1/1       Running   0          35s       10.1.1.1   kubeadm-worker0
bpod                        1/1       Running   0          19s       10.1.1.2   kubeadm-worker0
...
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
### <a name="ch2"></a> Chapter 2 - TCP Policy

In this section, we will create a TCP deny policy as well as a selective TCP port allow policy.

```
[vagrant@kubeadm-master ~]$ netctl policy rule-add -t TestTenant -d in --protocol tcp --port 0  --from-group epgA  --action deny policyAB 2
[vagrant@kubeadm-master ~]$ netctl policy rule-add -t TestTenant -d in --protocol tcp --port 8001  --from-group epgA  --action allow --priority 10 policyAB 3
[vagrant@kubeadm-master ~]$ netctl policy rule-ls -t TestTenant policyAB
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
Now check that from epgB, only TCP 8001 port is open. To test this, let's run `iperf` on bpod and verify using the `nc` utility on apod.

On bpod:

```
[vagrant@kubeadm-master ~]$ kubectl exec -it bpod sh
/ # iperf -s -p 8001
------------------------------------------------------------
Server listening on TCP port 8001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
```
Open another terminal and login to apod:

```
[vagrant@kubeadm-master ~]$ kubectl exec -it apod sh
/ # nc -zvw 1 10.1.1.2 8001     # here 10.1.1.2 is IP address of bpod.
10.1.1.2 (10.1.1.2:8001) open
/ # nc -zvw 1 10.1.1.2 8000
nc: 10.1.1.2 (10.1.1.2:8000): Operation timed out
/ # exit
```
We can see that port 8001 is open and port 8000 is not open. Exit bpod as well.

```
/ # iperf -s -p 8001
------------------------------------------------------------
Server listening on TCP port 8001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 10.1.1.2 port 8001 connected with 10.1.1.1 port 38137
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0- 0.0 sec  0.00 Bytes  0.00 bits/sec
^C/ # exit
```

### <a name="ch3"></a> Chapter 3 - Bandwidth Policy

In this chapter, we will explore the bandwidth policy feature of Contiv. We will create a tenant, a network and some groups. Then we will attach a netprofile to one endpoint group and verify that the applied bandwidth policy works as expected.

So, let's create a tenant, a network and group "A" under the network.

```
[vagrant@kubeadm-master ~]$ netctl tenant create BandwidthTenant
Creating tenant: BandwidthTenant
[vagrant@kubeadm-master ~]$ netctl network create --tenant BandwidthTenant --subnet=50.1.1.0/24 --gateway=50.1.1.254 -p 1001 -e "vlan" BandwidthTestNet
Creating network BandwidthTenant:BandwidthTestNet
[vagrant@kubeadm-master ~]$ netctl group create -t BandwidthTenant BandwidthTestNet epgA
Creating EndpointGroup BandwidthTenant:epgA
```
```
[vagrant@kubeadm-master ~]$ netctl net ls -a
Tenant           Network           Nw Type  Encap type  Packet tag  Subnet        Gateway     IPv6Subnet  IPv6Gateway  Cfgd Tag
------           -------           -------  ----------  ----------  -------       ------      ----------  -----------  ---------
...
TestTenant       TestNet           data     vlan        0           10.1.1.0/24   10.1.1.254
BandwidthTenant  BandwidthTestNet  data     vlan        1001        50.1.1.0/24   50.1.1.254
...
```
```
[vagrant@kubeadm-master ~]$ netctl group ls -a
Tenant           Group  Network           IP Pool  CfgdTag  Policies  Network profile
------           -----  -------           -------  -------  --------  ---------------
TestTenant       epgA   TestNet
TestTenant       epgB   TestNet                             policyAB
BandwidthTenant  epgA   BandwidthTestNet
```
Now, we are going to run two containers in the epgA network space: aserver and aclient.

```
[vagrant@kubeadm-master ~]$ cat <<EOF > aserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: aserver
  labels:
    app: aserver
    io.contiv.tenant: BandwidthTenant
    io.contiv.net-group: epgA
    io.contiv.network: BandwidthTestNet
spec:
  containers:
  - name: alpine
    image: contiv/alpine
    command:
      - sleep
      - "6000"
EOF

[vagrant@kubeadm-master ~]$ kubectl create -f aserver.yaml
pod "aserver" created
```
```
[vagrant@kubeadm-master ~]$ cat <<EOF > aclient.yaml
apiVersion: v1
kind: Pod
metadata:
  name: aclient
  labels:
    app: aclient
    io.contiv.tenant: BandwidthTenant
    io.contiv.net-group: epgA
    io.contiv.network: BandwidthTestNet
spec:
  containers:
  - name: alpine
    image: contiv/alpine
    command:
      - sleep
      - "6000"
EOF

[vagrant@kubeadm-master ~]$ kubectl create -f aclient.yaml
pod "aclient" created
```
```
[vagrant@kubeadm-master ~]$ kubectl get pods
NAME                        READY     STATUS    RESTARTS   AGE
aclient                     1/1       Running   0          6s
apod                        1/1       Running   0          13m
aserver                     1/1       Running   0          23s
bpod                        1/1       Running   0          13m
...
```
Now run `iperf` on the server and client to find out the current bandwidth policies which are on the network. It may vary depending upon base OS, network speed, etc.

On aserver:

```
[vagrant@kubeadm-master ~]$ kubectl exec -it aserver sh
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:32:01:01:01
          inet addr:50.1.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:32ff:fe01:101/64 Scope:Link
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

/ # iperf -s -u
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
```
Open up a new terminal and login to aclient:

```
[vagrant@kubeadm-master ~]$ kubectl exec -it aclient sh
/ # iperf -c 50.1.1.1 -u
------------------------------------------------------------
Client connecting to 50.1.1.1, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11215.21 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.2 port 46490 connected with 50.1.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec
[  3] Sent 893 datagrams
[  3] Server Report:
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec   0.008 ms    0/  893 (0%)
/ # exit
```
Exit aserver.

```
/ # iperf -s -u
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.1 port 5001 connected with 50.1.1.2 port 46490
[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec   0.009 ms    0/  893 (0%)
^C/ # exit
```
Now we see that the current bandwidth we are getting is 1.05 Mbits/sec. So let's create a new group B and create a netprofile with a bandwidth less than the one we got above: 500Kbits/sec bandwidth.

```
[vagrant@kubeadm-master ~]$ netctl netprofile create -t BandwidthTenant -b 500Kbps -d 6 -s 80 testProfile
Creating netprofile BandwidthTenant:testProfile

[vagrant@kubeadm-master ~]$ netctl group create -t BandwidthTenant -n testProfile BandwidthTestNet epgB
Creating EndpointGroup BandwidthTenant:epgB

[vagrant@kubeadm-master ~]$ netctl netprofile ls -a
Name         Tenant           Bandwidth  DSCP      burst size
------       ------           ---------  --------  ----------
testProfile  BandwidthTenant  500Kbps    6         80

[vagrant@kubeadm-master ~]$ netctl group ls -a
Tenant           Group  Network           IP Pool  CfgdTag  Policies  Network profile
------           -----  -------           -------  -------  --------  ---------------
TestTenant       epgA   TestNet
TestTenant       epgB   TestNet                             policyAB
BandwidthTenant  epgA   BandwidthTestNet
BandwidthTenant  epgB   BandwidthTestNet                              testProfile
```
Run bclient and bserver pods:

```
[vagrant@kubeadm-master ~]$ cat <<EOF > bserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: bserver
  labels:
    app: bserver
    io.contiv.tenant: BandwidthTenant
    io.contiv.net-group: epgB
    io.contiv.network: BandwidthTestNet
spec:
  containers:
  - name: alpine
    image: contiv/alpine
    command:
      - sleep
      - "6000"
EOF

[vagrant@kubeadm-master ~]$ kubectl create -f bserver.yaml
pod "bserver" created
```
```
[vagrant@kubeadm-master ~]$ cat <<EOF > bclient.yaml
apiVersion: v1
kind: Pod
metadata:
  name: bclient
  labels:
    app: bclient
    io.contiv.tenant: BandwidthTenant
    io.contiv.net-group: epgB
    io.contiv.network: BandwidthTestNet
spec:
  containers:
  - name: alpine
    image: contiv/alpine
    command:
      - sleep
      - "6000"
EOF

[vagrant@kubeadm-master ~]$ kubectl create -f bclient.yaml
pod "bclient" created
```
```
[vagrant@kubeadm-master ~]$ kubectl get pods
NAME                        READY     STATUS    RESTARTS   AGE
aclient                     1/1       Running   0          15m
apod                        1/1       Running   0          28m
aserver                     1/1       Running   0          15m
bclient                     1/1       Running   0          1m
bpod                        1/1       Running   0          28m
bserver                     1/1       Running   0          1m
...
```

Now we are running bclient and bserver pods on the group B network. We should see bandwidth around 500Kbps when we run `iperf`. Let's verify that our bandwidth netprofile is working as expected.

On bserver:

```
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:02:32:01:01:03
          inet addr:50.1.1.3  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::2:32ff:fe01:103/64 Scope:Link
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

/ # iperf -s -u
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
```
Open another terminal and login to bclient:

```
[vagrant@kubeadm-master ~]$ kubectl exec -it bclient sh
/ # iperf -c 50.1.1.3 -u
------------------------------------------------------------
Client connecting to 50.1.1.3, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11215.21 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.4 port 53775 connected with 50.1.1.3 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.25 MBytes  1.05 Mbits/sec
[  3] Sent 893 datagrams
[  3] Server Report:
[  3]  0.0-10.0 sec   620 KBytes   509 Kbits/sec   0.008 ms  461/  893 (52%)
/ # exit

```
Exit bserver.

```
/ # iperf -s -u
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 50.1.1.3 port 5001 connected with 50.1.1.4 port 53775
[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-10.0 sec   620 KBytes   509 Kbits/sec   0.009 ms  461/  893 (52%)
^C/ # exit
```
We can see that bclient is getting roughly around 500Kbps bandwidth.

### <a name="cleanup"></a> Cleanup

To cleanup the setup, after doing all the experiments, exit the VM and destroy the VMs:

```
[vagrant@kubeadm-master ~]$ exit
logout
Connection to 127.0.0.1 closed.
```

```
$ cd .. # go back to install directory
$ make cluster-destroyi
cd cluster && vagrant destroy -f
==> kubeadm-worker0: Forcing shutdown of VM...
==> kubeadm-worker0: Destroying VM and associated drives...
==> kubeadm-master: Forcing shutdown of VM...
==> kubeadm-master: Destroying VM and associated drives...
==> swarm-mode-worker0: VM not created. Moving on...
==> swarm-mode-master: VM not created. Moving on...
==> legacy-swarm-worker0: VM not created. Moving on...
==> legacy-swarm-master: VM not created. Moving on...
```
```
$ make vagrant-clean
vagrant global-status --prune
id       name   provider state  directory
--------------------------------------------------------------------
There are no active Vagrant environments on this computer! Or,
you haven't destroyed and recreated Vagrant environments that were
started with an older version of Vagrant.
cd cluster && vagrant destroy -f
==> kubeadm-worker0: VM not created. Moving on...
==> kubeadm-master: VM not created. Moving on...
==> swarm-mode-worker0: VM not created. Moving on...
==> swarm-mode-master: VM not created. Moving on...
==> legacy-swarm-worker0: VM not created. Moving on...
==> legacy-swarm-master: VM not created. Moving on...
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