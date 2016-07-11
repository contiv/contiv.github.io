---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-configuration"
description: |-
  Storage
---

# Configuration

This page describes ways to manipulate Contiv Storage through configuration and options.

## Volume Formatting

Because of limitations in the Docker volume implementation, we use a *pattern*
to describe volumes to Docker. This pattern is `policy-name/volume-name`, and
is supplied to `docker volume create --name` and transfers to `docker run -v`.

For example, the following commands illustrate a typical use of Contiv Storage presuming 
a policy named `policy1` has been uploaded:

```
$ docker volume create -d volplugin --name policy1/sample
$ docker run -it -v policy1/sample:/mnt ubuntu bash
```

This pattern creates a volume called `sample` in the default Ceph pool of `policy1`. 
See [Driver Options] for information about how to change the pool (or other options), 

## JSON Global Configuration

Global configuration modifies the whole system through the `apiserver`, `volplugin`
and 'volsupervisor' systems. You can manipulate these systems with the `volcli global`
command set.

A global configuration looks like the following:

```
javascript
{
  "TTL": 60,
  "Debug": true,
  "Timeout": 5,
  "MountPath": "/mnt/ceph"
}
```

The options are:

- `TTL`: Time (in seconds) for a mount record to timeout if a `volplugin` instance dies.
- `Debug`: Boolean value indicating whether or not to enable debug traps and logging.
- `Timeout`: A command is terminated if it runs longer than this time (in minutes).
- `MountPath`: The base path used for mount directories. Directories will be in `policy/volume` format at this root.

<a name="json_tenant_config"></a>
## JSON Tenant Configuration

Tenant configuration uses JSON to configure the default volume parameters such
as which pool to use. The JSON is uploaded to `etcd` by the `volcli` tool.

For example:

```javascript
{
  "backends": {
    "crud": "ceph",
    "mount": "ceph",
    "snapshot": "ceph"
  },
  "unlocked": false,
  "driver": {
    "pool": "rbd"
  },
  "create": {
    "size": "10MB",
    "filesystem": "btrfs"
  },
  "runtime": {
    "snapshots": true,
    "snapshot": {
      "frequency": "30m",
      "keep": 20
    },
    "rate-limit": {
      "write-iops": 1000,
      "read-iops": 1000,
      "write-bps": 100000000,
      "read-bps": 100000000
    }
  },
  "filesystems": {
    "ext4": "mkfs.ext4 -m0 %",
    "btrfs": "mkfs.btrfs %",
    "falsefs": "/bin/false"
  }
}
```

The parameters described by the JSON are:

- `unlocked`: Removes the exclusive locks between mounts for a given volume.
  - This is a protective measure and is *not needed* to use NFS, so this flag
    turns it off (by setting it to true) if desired for a given policy.
- `filesystems`: A policy-level map of filesystem *name* to *mkfs* command.
  - Commands are run when the filesystem is specified and the volume has not
    been created already.
  - Commands run in a POSIX (not bash or zsh) shell.
  - If the `filesystems` block is omitted, `mkfs.ext4 -m0 %` is applied to
    all volumes within this policy.
	- Referred to by the volume create-time parameter `filesystem`. A
	  `%` is replaced with the device to format.
- `backends`: The storage backends to use for different operations. Not all 
  drivers are compatible with each other. Ceph and NFS are supported as `mount` options.
  The `crud` and `snapshot` operations require Ceph. Both driver names are lower-case.
  - `crud`: Create-Delete operations driver name.
  - `mount`: Mount operations driver name.
  - `snapshot`: Snapshot operations.
- `driver`: Driver-specific options.
  - `pool`: The Ceph pool to use.
- `create`: Create-time options.
  - `size`: The size of the volume.
  - `filesystem`: The filesystem to use. See the `filesystems` parameter.
- `runtime`: Runtime options. These options can be changed and the changes are
  applied to mounted volumes almost immediately.
  - `snapshots`: Use the snapshots feature.
  - `snapshot`: Map of the following parameters:
    - `frequencyr: The amount of time between taking snapshots.
    - `keep`: The number of snapshots to keep. The oldest snapshots are deleted first.
  - `rate-limit`: Map of the following rate-limiting parameters:
    - `write-iops`: Write I/O weight.
    - `read-iops`: Read I/O weight.
    - `write-bps`: Write bytes/s.
    - `read-bps`: Read bytes/s.

You supply the parameters with the following command:

```
volcli policy upload <policy name>
```

The JSON itself is provided in standard input. For example, if your file is `policy2.json`:

```
$ volcli policy upload myTenant < policy2.json
```

<a name="driver_options"></>
## Driver Options

Driver options are passed at `docker volume create` time with the `--opt` flag.
They are `key=value` pairs. For example: 

```
docker volume create -d volplugin \
  --name policy2/image \
  --opt size=1000
```

The options are as follows:

* `size`: The size (in MB) of the volume.
* `snapshots`: Take snapshots or not. Affects future options with `snapshot` in the key name.
  * The value must satisfy [this specification](https://golang.org/pkg/strconv/#ParseBool)
* `snapshots.frequency`: The frequency which to take snapshots.
* `snapshots.keep`: The number of snapshots to keep.
* `filesystem`: The named filesystem to create. See the JSON Configuration
  section for more information on this.
* `rate-limit.write.iops`: Write IOPS
* `rate-limit.read.iops`: Read IOPS
* `rate-limit.read.bps`: Read b/s
* `rate-limit.write.bps`: Write b/s

## NFS Support

NFS support is limited. To use NFS support, do the following: 

1\. Ensure `nfs` is the `mount` backend for your policy, and that `crud` and `snapshot` are empty.
2\. Create your volume with the remote mount path specified at create time:

```
docker volume create -d volplugin --name mypolicy/myvolume --opt mount=127.0.0.1:/mynfsmount
```

3\. Mount the volume and continue as normal.

[Driver Options]: <#driver_options>
[JSON Tenant Configuration]: <#json_tenant_config>
