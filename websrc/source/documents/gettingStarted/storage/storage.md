---
layout: "documents"
page_title: "Getting Started with contiv storage"
sidebar_current: "getting-started-storage-swarm"
description: |-
  Getting Started
---

## Getting started with Contiv Storage

Getting started describes setting up a test environment with three VMs. Once
the test environment is setup see the [**Configure Services**](#Configure Services).

#### Prerequisites

Please read and follow the instructions in the prerequisites section of the
volplugin
[README](https://github.com/contiv/volplugin/blob/master/README.md#prerequisites)
before completing the following:

### Clone and build the project

### On Linux (without a VM)

Clone the project:

```
git clone https://github.com/contiv/volplugin
```

Build the project:

```
make run-build
```

The command `make run-build` installs utilities for building the software in
the `$GOPATH`, as well as the `volmaster`, `volplugin` and `volcli` utilities.

### Everywhere else (with a VM):

Clone the project:

```
git clone https://github.com/contiv/volplugin
```

Build the project:

```
make start
```

The build and binaries will be on the VM in the following directory `/opt/golang/bin`.

## Do it yourself

### Installing Dependencies

Use the Contiv [nightly releases](https://github.com/contiv/volplugin/releases)
when following these steps:

**Note:** Using the nightly builds is simpler than building the applications.

Install the dependencies in the following order:

1. Follow the [Getting Started](https://github.com/coreos/etcd/releases/tag/v2.2.0) to install [Etcd](https://coreos.com/etcd/docs/latest/getting-started-with-etcd.html).
  * Currently versions 2.0 and later are supported.

2. Follow the [Ceph Installation Guide](http://docs.ceph.com/docs/master/install/) to install [Ceph](http://ceph.com).
3. Configure Ceph with [Ansible](https://github.com/ceph/ceph-ansible).

  **Note**: See the [README](https://github.com/contiv/volplugin/blob/master/README.md#running-the-processes)
  for pre-configured VMs that work on any UNIX operating system to simplify
    Ceph installation.

4. Upload a global configuration. You can find an example one [here](https://github.com/contiv/volplugin/blob/master/systemtests/testdata/global1.json)

5. Start volmaster (as root):

```
volmaster &
```

**Note**: volmaster debug mode is very noisy and is not recommended for
production use. Therefore, avoid using it with background processes. volplugin
currently connects to volmaster using port 9005, however in the future it is
variables.

6. Start volsupervisor (as root):

```
volsupervisor &
```


**Note**: volsupervisor debug mode is very noisy and is not recommended for production.

7.  Start volplugin (as root):

```
volplugin &
```

If running volplugin on multiple hosts, use the `--master` flag to
provide a ip:port pair to connect to over http. By default it connects to
`127.0.0.1:9005`.

## Configure Services

Ensure Ceph is fully operational, and that the `rbd` tool works as root.

Upload a policy:

```
volcli policy upload policy1 < mypolicy.json
```

**Note**: It accepts the policy from stdin, e.g.: `volcli policy upload policy1 < mypolicy.json`
Examples of a policy are in [systemtests/testdata](https://github.com/contiv/volplugin/tree/master/systemtests/testdata).
