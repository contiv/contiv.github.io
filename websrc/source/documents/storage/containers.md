---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-containers"
description: |-
  Storage
---

### Creating a Container with a Volume

To create a container with a volume, create a volume that refers to the `volplugin` driver:

```
docker volume create -d volplugin --name policy1/test
```

Note the following:

The name of the volume is `test`. The volumen is located under policy `policy1`,
 which is uploaded with `volcli policy upload`.

The volume inherits the properties of the policy: *size*, *iops*, and so on.

There are numerous options (see below) to declare overrides of most parameters in the policy configuration.

To run a container that uses the policy, do the following:

1\. Run the command:

```
docker run -it -v policy1/test:/mnt ubuntu bash
```

2\. Run `mount | grep /mnt` in the container.


*Note*: `/dev/rbd#`should be attached to the `mnt` directory.

Once a multi-host system is set up, anytime the volume is not mounted, it
can be mounted on any host that has a connected `rbd` client available and
`volplugin` running.
