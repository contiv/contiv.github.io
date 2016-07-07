---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-architecture"
description: |-
  Storage
---

## Architecture

"volplugin", despite the name, is actually a suite of components:

`apiserver` is the api service process. It exists to give `volcli` a way to
coordinate with the cluster at large.  It talks to `etcd` to keep its state.

`volplugin` is the plugin process. It manages the lifecycle of mounts on
specific hosts, and manages the local operations for CRUD and runtime parameter
management.

`volcli` is a utility for managing `apiserver`'s data. It makes both REST calls
into the apiserver and additionally can write directly to etcd.

### Organizational Architecture

`apiserver` will need to be contacted by volcli and lives anywhere it can reach etcd.

`volsupervisor` handles scheduled and supervised tasks such as snapshotting. It
may only be deployed on one host at a time.

`volplugin` needs to run on every host that will be running containers. Upon
start, it will create a unix socket in the appropriate plugin path so that
docker recognizes it. This creates a driver named `volplugin`.

`volcli` is a management tool and can live anywhere that has access to the etcd
cluster and apiserver.

### Security Architecture

There is none currently. This is still an alpha, security will be a beta
target.

### Network Architecture

`apiserver`, by default, listens on `0.0.0.0:9005`. It provides a REST
interface to each of its operations that are used both by `volplugin` and
`volcli`. It connects to etcd at `127.0.0.1:2379`, which you can change by
supplying `--etcd` one or more times.

`volsupervisor` needs root, connections to etcd, and access to ceph `rbd` tools
as admin.

`volplugin` listens on no network ports (it uses a unix socket as described
above, to talk to docker). It connects to etcd at `127.0.0.1:2379`, which you
can change by supplying `--etcd` one or more times.

`volcli` talks to both `apiserver` and `etcd` to communicate various state and
operations to the system.
