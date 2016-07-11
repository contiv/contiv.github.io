---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-architecture"
description: |-
  Storage
---

# Architecture

Contiv Storage consists of a suite of four components:

The `volplugin` process is a plugin process that manages the lifecycle of volume mounts on
specific hosts and local create, read, update delete (CRUD) operations and runtime parameter
management. 

The `apiserver` process is the API service. It exists to give `volcli` a way to
coordinate with the cluster at large.  It store state with the `etcd` service.

The `volcli` utility manages the `apiserver`'s data. It both makes REST calls
into `apiserver` and additionally can write directly to etcd.

The `volsupervisor` service handles scheduled and supervised tasks such as snapshotting. 

## Organizational Architecture

The `apiserver` process can be installed anywhere it is able to contact `etcd`, 
and must be reachable by `volcli`.

The `volsupervisor` service must only be deployed on one host at a time.

The `volplugin` component must run on every host that runs containers. On
startup, it creates a UNIX socket in the appropriate plugin path so that
Docker recognizes it. This creates a driver named `volplugin`.

The `volcli` utility is a management tool and can be run anywhere that has access to 
the `etcd` cluster and `apiserver`.

## Security Architecture

There is none currently. This is still an alpha, security will be a beta
target.

## Network Architecture

The `apiserver`, by default, listens on `0.0.0.0:9005`. It provides a REST
interface used both by `volplugin` and `volcli`. It connects to `etcd` at `127.0.0.1:2379`.
You can change the `etcd` address and port by supplying `--etcd` one or more times.

The `volsupervisor` service needs root access, a connection to `etcd`, and access to 
ceph `rbd` tools as *admin*.

The `volplugin` component listens on no network ports (it uses a UNIX socket, as described
above, to connect to Docker). It connects to `etcd` at `127.0.0.1:2379`. You can
can change the `etcd` address and port by supplying `--etcd` one or more times.

The `volcli` utility connects to `apiserver` and `etcd` to communicate various state and
operations to the system.
