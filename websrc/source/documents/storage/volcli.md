---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-volcli"
description: |-
  Storage
---

# Contiv Storage Command Reference

The `volcli` command invokes API calls on  the `apiserver` service, which in turn 
is referenced by the `volplugin` component for local management of storage. 
Think of `volcli` as a tap into the control plane.

## Top-Level Commands

These commands present CRUD options on their respective sub-sections:

* `volcli global` manipulates global configuration.
* `volcli policy` manipulates policy configuration.
* `volcli volume` manipulates volumes.
* `volcli mount` manipulates mounts.
* `volcli help` prints the help messages.
  * For each subcommand, `volcli help [subcommand]` prints the help message
    for [subcommand]. For multi-level commands, `volcli [subcommand] help
    [subcommand]` provides appropriate help. Appending `--help` to any command prints the
    help as well.

## Global Commands

* `volcli global upload` takes JSON global configuration from the standard input.
* `volcli global get` retrieves the JSON global configuration.

## Tenant Commands

Typing `volcli policy` without arguments prints help for these commands.

* `volcli policy upload` takes a policy name and JSON configuration from standard input.
* `volcli policy delete` removes a policy. The policy's volumes and mounts are not removed.
* `volcli policy get` displays the JSON configuration for a policy.
* `volcli policy list` lists the policies contained in etcd.

## Volume Commands

Typing `volcli volume` without arguments prints help for these commands.

* `volcli volume create` forcefully creates a volume just as if it were created with
  `docker volume create`. Requires a policy and volume name.
* `volcli volume get` retrieves the volume configuration for a given policy/volume combination.
* `volcli volume list` lists all the volumes for a provided policy.
* `volcli volume list-all` lists all volumes, across policies.
* `volcli volume remove` removes a volume given a policy/volume
  combination, deleting the underlying data.  This operation may fail if the
  device is mounted, or expected to be mounted.
* `volcli volume force-remove`, given a policy/volume combination, removes
  the data from etcd but does not perform any other operations. Use this option with
  caution.
* `volcli volume runtime get` retrieves the runtime policy for a given volume.
* `volcli volume runtime upload` uploads (via stdin) the runtime policy for a given volume.

## Mount Commands

Typing `volcli mount` without arguments prints help for these commands.

*Note:* `volcli mount` cannot control mounts - this is managed by
`volplugin` which runs on each host. 

* `volcli mount list` lists all known mounts in etcd.
* `volcli mount get` obtains specific information about a mount from etcd.
* `volcli mount force-remove` removes the contents from etcd, but does not
  attempt to perform any unmounting. This is useful for removing mounts that
  fail for some reason (e.g., host failure, which is not currently satsified by
  volplugin).

## Use Commands

Use commands control the locking system and also provide information about what
is being used by what. Use these commands with caution as they can affect the
stability of the cluster if used improperly.

* `volcli use list` lists all uses (mounts, snapshots) in effect.
* `volcli use get` gets information on a specific use lock.
* `volcli use force-remove` forces a lock open for a given volume.
* `volcli use exec` waits for a lock to free, then executes the supplied command.
