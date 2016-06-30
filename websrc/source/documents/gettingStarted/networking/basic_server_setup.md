---
layout: "install"
page_title: "Basic Setup"
sidebar_current: "getting-started-server-setup"
description: |-
  Basic Server Setup for Contiv
---

## Contiv Networking on Servers or VMs

This page describes how to set up a basic Contiv networking cluster with two or more Linux servers.

### Prerequisites

1. Install Ubuntu 15 or Centos 7 on all servers used for the Contiv cluster.
2. Choose one node to use as the installation and control node for the cluster (the "installation
node"). Perform all the following steps on that node.  
3. Execute the following shell commands on all nodes used for the cluster:  
```export CLUSTER_NODE_IPS=<cluster_IPs>  
export no_proxy=<cluster_IPs>,127.0.0.1,localhost,netmaster```   
where ```<cluster_IPs> is a list of the IP addresses of all interfaces of every node used for the cluster.  
4. If your servers are behind an HTTP proxy, execute the following shell commands:  
```export http_proxy=<proxy_ url>  
export https_proxy=<proxy_url>```  
5. (Optional but strongly recommended) Enable passwordless SSH access from the installation server  
to all the other servers in the cluster.  An example is [here](http://www.linuxproblem.org/art_9.html).  

6. (Optional but strtongly recommended) Enable passwordless sudo on all servers. 
An example is [here](http://askubuntu.com/questions/192050/how-to-run-sudo-command-with-no-password).

7. Make a note of the IP addresses (or DNS names) of all the servers, and of the network 
interfaces on which these IP addresses are configured.

### Step 1: Download the Installer Script

On the installation server, download the installer script using the following command:

```
wget https://raw.githubusercontent.com/contiv/demo/master/net/net_demo_installer
```

### Step 2: Specify Configuration
On the installation server, create a configuration file. We reccommend you name it
something like `cfg.yml`. 

The configuration file can contain many parameters. For now just include the minimum
information that must be in the file: the IP address (or DNS name) of every node
used in the cluster, and the name of the two interface on each node used for control
and data. The file should have the following form:

```
      CONNECTION_INFO:
      <server1-ip-or-dns>:
        control: <interface on which control protocols can interact>
        data: <interface used to send data packets>
      <server2-ip-or-dns>:
        control: <interface on which control protocols can interact>
        data: <interface used to send data packets>
```

[A configuration template is here](sample_cfg.yml).

### Step 3: Make The Script Executable
Make the installer script executable with the following command:

```
chmod +x net_demo_installer
```

### Step 4: Run The Script
Run net_demo_installer script:

```
./net_demo_installer
```

The installer script asks for a username and password if passwordless ssh is not set.

The installer script performs the following actions:

- Verifies that a supported OS version is installed on the servers.
- Verifies access to the servers. 
- Creates the ansible inventory file.
- Sets variables needed to provision the servers in the correct mode.
- Runs the Ansible playbook, which installs packages and starts the services.

The script generates many bookkeeping files during the installation in the `.gen` folder in your installer directory.
To remove these files, use the `-c` option: 

```./net_demo_installer -c```

To restart the demo sever, use the `-r` option: 

```
./net_demo_installer -r
```

### What to Do Next
You can now use Contiv Network on the demo setup. See [docs.contiv.io](http://docs.contiv.io).

### If You Encounter Problems
The script has the following limitations:
- The installer script must run from one of the server nodes in the cluster.
-  the servers accept ssh connections only on the default ssh port, using the default username.

