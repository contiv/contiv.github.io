---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-volcli"
description: |-
  Storage
---

## volcli Reference

`volcli` controls the `apiserver`, which in turn is referenced by the
`volplugin` for local management of storage. Think of volcli as a tap into the
control plane.

### Top-Level Commands

These commands present CRUD options on their respective sub-sections:

* `volcli global` manipulates global configuration.
* `volcli policy` manipulates policy configuration.
* `volcli volume` manipulates volumes.
* `volcli mount` manipulates mounts.
* `volcli help` prints the help.
  * Note that for each subcommand, `volcli help [subcommand]` will print the
    help for that command. For multi-level commands, `volcli [subcommand] help
    [subcommand]` will work. Appending `--help` to any command will print the
    help as well.

### Global Commands

* `volcli global upload` takes JSON global configuration from the standard input.
* `volcli global get` retrieves the JSON global configuration.

### Tenant Commands

Typing `volcli policy` without arguments will print help for these commands.

* `volcli policy upload` takes a policy name, and JSON configuration from standard input.
* `volcli policy delete` removes a policy. Its volumes and mounts will not be removed.
* `volcli policy get` displays the JSON configuration for a policy.
* `volcli policy list` lists the policies etcd knows about.

### Volume Commands

Typing `volcli volume` without arguments will print help for these commands.

* `volcli volume create` will forcefully create a volume just like it was created with
  `docker volume create`. Requires a policy, and volume name.
* `volcli volume get` will retrieve the volume configuration for a given policy/volume combination.
* `volcli volume list` will list all the volumes for a provided policy.
* `volcli volume list-all` will list all volumes, across policies.
* `volcli volume remove` will remove a volume given a policy/volume
  combination, deleting the underlying data.  This operation may fail if the
  device is mounted, or expected to be mounted.
* `volcli volume force-remove`, given a policy/volume combination, will remove
  the data from etcd but not perform any other operations. Use this option with
  caution.
* `volcli volume runtime get` will retrieve the runtime policy for a given volume
* `volcli volume runtime upload` will upload (via stdin) the runtime policy for a given volume

### Mount Commands

Typing `volcli mount` without arguments will print help for these commands.

**Note:** `volcli mount` cannot control mounts -- this is managed by
`volplugin` which lives on each host. Eventually there will be support for
pushing operations down to the volplugin, but not yet.

* `volcli mount list` lists all known mounts in etcd.
* `volcli mount get` obtains specific information about a mount from etcd.
* `volcli mount force-remove` removes the contents from etcd, but does not
  attempt to perform any unmounting. This is useful for removing mounts that
  for some reason (e.g., host failure, which is not currently satsified by
  volplugin)

### Use Commands

Use commands control the locking system and also provide information about what
is being used by what. Use these commands with caution as they can affect the
stability of the cluster if used improperly.

* `volcli use list` will list all uses (mounts, snapshots) in effect.
* `volcli use get` will get information on a specific use lock.
* `volcli use force-remove` will force a lock open for a given volume.
* `volcli use exec` will wait for a lock to free, then execute hte command.
