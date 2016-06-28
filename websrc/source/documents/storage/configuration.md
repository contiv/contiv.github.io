---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-configuration"
description: |-
  Storage
---

## Configuration

This section describes various ways to manipulate volplugin through
configuration and options.

### Volume Formatting

Because of limitations in the docker volume implementation, we use a *pattern*
to describe volumes to docker. This pattern is `policy-name/volume-name`, and
is supplied to `docker volume create --name` and transfers to `docker run -v`.

For example, a typical use of volplugin might work like this presuming we have
a policy uploaded named `policy1`:

```
$ docker volume create -d volplugin --name policy1/foo
$ docker run -it -v policy1/foo:/mnt ubuntu bash
```

This pattern creates a volume called `foo` in `policy1`'s default ceph pool. If
you wish to change the pool (or other options), see "Driver Options" below.

### JSON Global Configuration

Global configuration modifies the whole system through the volmaster, volplugin
and volsupervisor systems. You can manipulate them with the `volcli global`
command set.

A global configuration looks like this:

```javascript
{
  "TTL": 60,
  "Debug": true,
  "Timeout": 5,
  "MountPath": "/mnt/ceph"
}
```

Options:

* TTL: time (in seconds) for a mount record to timeout in the event a volplugin dies
* Debug: boolean value indicating whether or not to enable debug traps/logging
* Timeout: time (in minutes) for a command to be terminated if it exceeds this value
* MountPath: the base path used for mount directories. Directories will be in
  `policy/volume` format off this root.

### JSON Tenant Configuration

Tenant configuration uses JSON to configure the default volume parameters such
as what pool to use. It is uploaded to etcd by the `volcli` tool.

Here is an example:

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

Let's go through what these parameters mean.

* `unlocked`: removes the exclusive locks between mounts for a given volume.
  * This is a protective measure and is *not needed* to use NFS, so this flag
    will turn it off (by setting it to true) if desired for a given policy.
* `filesystems`: a policy-level map of filesystem name -> mkfs command.
  * Commands are run when the filesystem is specified and the volume has not
    been created already.
  * Commands run in a POSIX (not bash, zsh) shell.
  * If the `filesystems` block is omitted, `mkfs.ext4 -m0 %` will be applied to
    all volumes within this policy.
	* Referred to by the volume create-time parameter `filesystem`. Note that you
	  can use a `%` to be replaced with the device to format.
* `backends`: the storage backends to use for different operations. Note that
  not all drivers are compatible with each other. This is still an area with
  work being done on it. Ceph and NFS are supported as `mount` options, `crud`
  and `snapshot` operations require Ceph for now. Both driver names are lower-case.
  * `crud`: Create/Delete operations driver name
  * `mount`: Mount operations driver name
  * `snapshot`: Snapshot operations
* `driver`: driver-specific options.
	* `pool`: the ceph pool to use
* `create`: create-time options.
	* `size`: the size of the volume
  * `filesystem`: the filesystem to use, see `filesystems` above.
* `runtime`: runtime options. These options can be changed and the changes will
  be applied to mounted volumes almost immediately.
  * `snapshots`: use the snapshots feature
  * `snapshot`: map of the following parameters:
    * `frequency`: the amount of time between taking snapshots.
    * `keep`: the number of snapshots to keep. the oldest ones will be deleted first.
  * `rate-limit`: map of the following rate-limiting parameters:
    * `write-iops`: Write I/O weight
    * `read-iops`: Read I/O weight
    * `write-bps`: Write bytes/s
    * `read-bps`: Read bytes/s

You supply them with `volcli policy upload <policy name>`. The JSON itself is
provided via standard input, so for example if your file is `policy2.json`:

```
$ volcli policy upload myTenant < policy2.json
```

### Driver Options

Driver options are passed at `docker volume create` time with the `--opt` flag.
They are `key=value` pairs and are specified as such, f.e.:

```
docker volume create -d volplugin \
  --name policy2/image \
  --opt size=1000
```

The options are as follows:

* `size`: the size (in MB) for the volume.
* `snapshots`: take snapshots or not. Affects future options with `snapshot` in the key name.
  * the value must satisfy [this specification](https://golang.org/pkg/strconv/#ParseBool)
* `snapshots.frequency`: as above in the previous chapter, the frequency which we
  take snapshots.
* `snapshots.keep`: as above in the previous chapter, the number of snapshots to keep.
* `filesystem`: the named filesystem to create. See the JSON Configuration
  section for more information on this.
* `rate-limit.write.iops`: Write IOPS
* `rate-limit.read.iops`: Read IOPS
* `rate-limit.read.bps`: Read b/s
* `rate-limit.write.bps`: Write b/s

### NFS Support

NFS support is still limited (at the time of this writing). To use the NFS
support in its current state you must take a few steps.

1. Ensure "nfs" is the "mount" backend for your policy. `crud` and `snapshot`
should be empty.
2. Create your volume with the remote mount path specified at create time:

    ```
    docker volume create -d volplugin --name mypolicy/myvolume --opt mount=127.0.0.1:/mynfsmount
    ```

3. Mount and continue as normally.
