---
layout: "documents"
page_title: "Getting Started with contiv storage"
sidebar_current: "getting-started-storage-swarm"
description: |-
  Getting Started
---

# Getting Started with Contiv Storage

### Prerequisites

* Docker 1.11
* Working ceph installation on the host

### Installation

Run these commands on your docker host:

```
docker run -it -v /var/run/docker.sock:/var/run/docker.sock contiv/volplugin-autorun
```

This will configure all the services in your docker with the latest
contiv/volplugin release.

## Development Instructions

## Prerequisites
Your machine must have 12GB of free RAM. (Ceph is memory intensive.)

Install the following packages on your Linux or OS X machine:

- VirtualBox 5.0.2 or later
- Vagrant 1.8.x
- Ansible 2.0+
- Git
- Go 1.6, if you want to run the system tests

## Clone and Build the Project
The following instructions enable you to run an automated install process that creates a development
environment on either a Linux machine or on a Linux, OS X, or Windows machine running a Linux VM. 

### On Linux (without a VM)

1\. Clone the project:  

```  
git clone https://github.com/contiv/volplugin  
```  

2\. Build the project:

The `make run-build` command installs utilities for building the software in
the `$GOPATH`, and installs the the `volmaster`, `volplugin`, and `volcli` utilities.

```
make run-build
```

### With a VM, on Any Operating System

1\. Clone the project:

```
git clone https://github.com/contiv/volplugin
```

2\. Build the project:

The `make start` command installs the build and binary files on 
the VM in the directory `/opt/golang/bin` and starts the services on the VM.

```
make start
```

## Installing Without the Scripts

Following are instructions on how to install Contiv Storage without using the 
setup scripts.  Use the Contiv [nightly releases](https://github.com/contiv/volplugin/releases)
when following these steps.

*Note:* You can avoid building the applications by using the nightly builds. 

### Installing Dependencies

Install the dependencies in the following order:

1\. Install `etcd`
Follow the instructions [here](https://github.com/coreos/etcd/releases/tag/v2.2.0) 
instructions to install *[etcd](https://coreos.com/etcd/docs/latest/getting-started-with-etcd.html)*.
Install version 2.0 or later.

2\. Install Ceph
Follow the [Ceph Installation Guide](http://docs.ceph.com/docs/master/install/) to install [Ceph](http://ceph.com).

3\. Configure Ceph 
Configure Ceph with [Ansible](https://github.com/ceph/ceph-ansible).

*Note*: See the Contiv Storage 
[README here](https://github.com/contiv/volplugin/blob/master/README.md#running-the-processes)
  for pre-configured VMs that work on any UNIX operating system to simplify
    Ceph installation.

4\. Upload a Configuration
Upload a global configuration. You can find an example configuration 
[here](https://raw.githubusercontent.com/contiv/volplugin/master/systemtests/testdata/globals/global1.json).

5\. Start the Master Process
Log in as root, then start the `volmaster` process :

```
apiserver &
```

*Note*: `volmaster` debug mode produces a lot of output and is not recommended for
production use. Therefore, avoid using it with background processes. The `volplugin`
process connects to `volmaster` using port 9005.

6\. Start the Supervisor Process
Log in as root, then start `volsupervisor`:

```
volsupervisor &
```

*Note*: `volsupervisor` debug mode produces a lot of output and is not recommended for
production use. Therefore, avoid using it with background processes. 

7\.  Start the Contiv Plugin
Log in as root, then start `volplugin`:

```
volplugin &
```

If you run `volplugin` on multiple hosts, use the `--master` flag to
provide an ip:port pair to reach the process over http. By default 
this port is `127.0.0.1:9005`.

### Configure Services

Ensure that Ceph is fully operational, and that the `rbd` tool works as root.

Upload a policy:

```
volcli policy upload policy1 < mypolicy.json
```

Note that `volcli` reads the policy from *stdin*.

You can find example policies in 
[systemtests/testdata](https://github.com/contiv/volplugin/tree/master/systemtests/testdata).

## What to Do Next
Once the test environment is set up, see the instructions on how to 
[Configure Services](/documents/storage/configuration.html).
