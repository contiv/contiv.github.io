---
layout: "documents"
page_title: "Storage"
sidebar_current: "storage-containers"
description: |-
  Storage
---

### Creating a container with a volume

Create a volume that refers to the volplugin driver:

```
docker volume create -d volplugin --name policy1/test
```

**Notes**:

* `test` is the name of the volume, and is located under policy `policy1`,
 which is uploaded with `volcli policy upload.`
* The volume will inherit the properties of the policy. Therefore, the
volume will be of appropriate size, iops, etc.
* There are numerous options (see below) to declare overrides of most parameters in the policy configuration.
* Run a container that uses the policy:

```
docker run -it -v policy1/test:/mnt ubuntu bash
```
* Run `mount | grep /mnt` in the container.


**Note**: `/dev/rbd#`should be attached to that directory.

* Once a multi-host system is setup, anytime the volume is not mounted, it
can be mounted on any host that has a connected rbd client available, and
volplugin running.
