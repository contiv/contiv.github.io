---
layout: "documents"
page_title: "Getting Started"
sidebar_current: "tutorials-contiv-compose"
description: |-
  Getting Started
---

# Policies with Networking

This tutorial shows how to use a modified *libcompose* utility to apply network policies on a Docker application composition.

*Note*: The demonstrations on this page use the Vagrant utility to set up a VM environment. This environment is for demonstrating automation and integration with Contiv Networking and is not meant to be used in production.

## Getting Started
The following steps describe how to set up a demo application and apply policies to it.

### Prerequisites
Before starting, install the following tools on your Linux or OS X machine:

- Make
- Git

### 1. Start the Vagrant Environment
Use the following commands to start a Contiv Vagrant setup.

```
$ cd $HOME; mkdir -p deploy/src/github.com/contiv
$ export GOPATH=$HOME/deploy
$ cd deploy/src/github.com/contiv/
$ git clone https://github.com/contiv/netplugin
$ cd netplugin; make demo
```

### 2. Download the Software

Get `libcompose` and log into a VM using the following commands:

```
$ mkdir -p $GOPATH/src/github.com/docker
$ cd $GOPATH/src/github.com/docker
$ git clone https://github.com/jainvipin/libcompose
$ cd $GOPATH/src/github.com/contiv/netplugin
$ make ssh
```

### 3. Compile the Software
While logged into the VM, do the following to compile *libcompose*:

```
$ cd $GOPATH/src/github.com/docker/libcompose
$ git checkout deploy
$ make binary
$ sudo cp $GOPATH/src/github.com/docker/libcompose/bundles/libcompose-cli /usr/bin/contiv-compose
```

### 4. Build or Get Container Images
You can either build your own container images or download pre-built standard Docker images. 

You need two images, the *web* image and the *database* or *DB* image.

To build the web image, use the following commands:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example/app
$ docker build -t web .
```

To use the pre-built web images from the Docker repository, do the following instead:

```
$ docker pull jainvipin/web
$ docker tag jainvipin/web web
```

Next, build or download the database image.

To build the database image:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example/db
$ docker build -t redis -f Dockerfile.redis .
```

To download the database image:

```
$ docker pull jainvipin/redis
$ docker tag jainvipin/redis redis
```

(Optional) Run Contiv-UI
Contiv UI allows visual way of creating and monitoring Contiv network and storage policies.
To run contiv UI, run the following container, after which the container can be accessed on
port `80` inside the VM or on a mapped port like `9998` in the Vagrant environment

```
docker run --net=host --name contiv-ui -d contiv/contiv-ui
```

### 5. Build Networks and Create Policies
To demo the policies, first create a network as follows:

```
netctl net create -s 10.11.1.0/24 dev
```

Run `contiv-compose` to create a policy, as follows:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example
$ contiv-compose up -d
```

The system displays notifications similar to the following:

```
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose)
INFO[0000] Creating policy contract from 'web' -> 'redis'
INFO[0000] Using default policy 'TrustApp'...           
INFO[0000] User 'vagrant': applying 'TrustApp' to service 'redis'
INFO[0000]   Fetched port/protocol) = tcp/5001 from image
INFO[0000]   Fetched port/protocol) = tcp/6379 from image
INFO[0000] Project [example]: Starting project          
INFO[0000] [0/2] [web]: Starting                        
INFO[0000] [0/2] [redis]: Starting                      
INFO[0000] [1/2] [redis]: Started                       
INFO[0001] [2/2] [web]: Started        
```

Observe the following:

- For user `vagrant`, `contiv-compose` assigned the default policy, named `TrustApp`. The `TrustApp` policy can be found in the `ops.json` file, which is a modifiable ops policy in the example directory where you ran the `contiv-compose` command.
- As defined in `ops.json`, the TrustApp policy permits all ports allowed by the application. The notification messages show that `contiv-compose` tries to fetch the port information from the redis image and applies an inbound set of rules to it.

Now, verify that the isolation policy is working as expected:

```
$ docker exec -it example_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.dev.default [10.11.1.21] 6380 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6379 (?) open
example_redis.dev.default [10.11.1.21] 6378 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6377 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6376 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6375 (?) : Connection timed out

# exit
< ** back to linux prompt ** >
```

### 6. Stop the Composition
Stop the composition and associated policies with the following commands:

```
$ cd $GOPATH/src/github.com/docker/libcompose/deploy/example
$ contiv-compose stop
```

## Going Further
Below are some more cases that you can demo using this Vagrant setup.

### 1. Scaling an Application Tier

You can scale any application tier. A policy belonging to a tier, service, or group is applied correctly as you scale the tier.

1\. Start the previous example, then use the following commands to scale the web tier:

```
$ contiv-compose up -d
$ contiv-compose scale web=5
```

2\. Log into any container in the web tier and verify the policy is being enforced. For example:

```
$ docker exec -it example_web_3 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.dev.default [10.11.1.21] 6380 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6379 (?) open
example_redis.dev.default [10.11.1.21] 6378 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6377 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6376 (?) : Connection timed out
example_redis.dev.default [10.11.1.21] 6375 (?) : Connection timed out

# exit

$ contiv-compose stop
$ contiv-compose rm -f
```

### 2. Changing the Default Network
You can change the default network. The default policy is still applied.

1\. Create a new network called `test`:

```
netctl net create -s 10.22.1.0/24 test
```

2\. Start a composition in the new network. To do so, edit the `docker-compose.yml` file to look like the following:

```
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
  net: test
redis:
  image: redis
  net: test
```

3\. Start the composition:

Please note that the yaml file is sensitve to the extra whitespaces, and with improper alignment, `contiv-compose` would fail. To
avoid this please make sure the yaml file has exact same alignment as the code shown above.

```
$ contiv-compose up -d
```

The new composition runs in the `test` network as specified in the config file, while
policies are instantiated between the containers in test network

4\. Verify the policy between the containers as before:

```
$ docker exec -it example_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.test.default [10.11.1.21] 6380 (?) : Connection timed out
example_redis.test.default [10.11.1.21] 6379 (?) open
example_redis.test.default [10.11.1.21] 6378 (?) : Connection timed out
example_redis.test.default [10.11.1.21] 6377 (?) : Connection timed out
example_redis.test.default [10.11.1.21] 6376 (?) : Connection timed out
example_redis.test.default [10.11.1.21] 6375 (?) : Connection timed out
# exit
$
```

To quit, stop the composition:

```
$ contiv-compose stop
```

### 3. Specfying an Override Policy
You can override the default policy.

1\. Use a *policy label* to specify an override policy for a service tier.

The following composition file has been modified to override the default policy:

```
web:
  image: web
  ports:        
   - "5000:5000"
  links:
   - redis
  net: test
redis:
  image: redis  
  net: test       
  labels:         
   io.contiv.policy: "RedisDefault"
```

Override policies for various users are specified outside the application composition in an 
operational policy file (ops.json), which states that vagrant user is allowed to use the policies *TrustApp*,
*RedisDefault*, and *WebDefault*:

```
                { "User":"vagrant",
                  "DefaultTenant": "default",
                  "Networks": "test,dev",
                  "DefaultNetwork": "dev",
                  "NetworkPolicies" : "TrustApp,RedisDefault,WebDefault",
                  "DefaultNetworkPolicy": "TrustApp" }
```

The override policy called `RedisDefault` is defined later in the file as:

```
                { "Name":"RedisDefault",
                  "Rules": ["permit tcp/6379", "permit tcp/6378", "permit tcp/6377"] },
```

2\. Start the composition and verify that appropriate ports are open:`

```
$ contiv-compose up -d

$ docker exec -it example_web_1 /bin/bash
< ** inside container ** >
# nc -zvw 1 example-redis 6375-6380
example_redis.test.default [10.22.1.26] 6380 (?) : Connection timed out
example_redis.test.default [10.22.1.26] 6379 (?) open
example_redis.test.default [10.22.1.26] 6376 (?) : Connection timed out
example_redis.test.default [10.22.1.26] 6375 (?) : Connection timed out
# exit
$
```

Note that ports 6377-6379 are not `timing out`, which means that network is
not dropping packets sent to the target `example_redis` service. The reason
only `6379` shows open is because redis container is listening on the port.

3\. Stop and clean up the demo environment:

```
$ contiv-compose stop
```

### 4. Verifying Role Based Access to Disallow Network Access

If a composition attempts to specify a network forbidden to it, contiv-compose produces an error.

1\. Create a "production" network:

```
$ netctl net create -s 10.33.1.0/24 production

$ cat docker-compose.yml
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
  net: production
redis:
  image: redis
  net: production
```

2\. Start the composition and note the error message produced because of the unauthorized network:

```
$ contiv-compose up -d
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose)
ERRO[0000] User 'vagrant' not allowed on network 'production'
```

### 5. Verifying Role Based Access to Disallow a Network Policy

If a composition attempts to specify a disallowed policy, contiv-compose produces an error.

1\. Specify an `AllPriviliges` policy for the vagrant user. The expected error results:

```
$ cat docker-compose.yml
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
redis:
  image: redis
  labels:
   io.contiv.policy: "AllPriviliges"

$ contiv-compose up -d
WARN[0000] Note: This is an experimental alternate implementation of the Compose CLI (https://github.com/docker/compose)
INFO[0000] Creating policy contract from 'web' -> 'redis'
ERRO[0000] User 'vagrant' not allowed to use policy 'AllPriviliges'
ERRO[0000] Error obtaining policy : Deny disallowed policy  
ERRO[0000] Failed to apply in-policy for service 'redis': Deny disallowed policy
FATA[0000] Failed to Create Network Config: Deny disallowed policy
```

### 6. Specifying an Override Tenant for applications to run in

You can use contiv-compose to run the applications in a non-default tenant.

*Note*: This example is for illustration only. The tenant identity is typically retrieved from the user's context, and users are not allowed to specify the tenant.

1\. Create a new tenant called `blue` and specify a network called `dev` in the `blue` tenant:

```
netctl tenant create blue
netctl net create -t blue -s 10.11.2.0/24 dev
```

2\. Create a composition that states the tenancy as follows:

```
$ cat docker-compose.yml
web:
  image: web
  ports:
   - "5000:5000"
  links:
   - redis
  labels:
   io.contiv.tenant: "blue"
redis:
  image: redis
  labels:
   io.contiv.tenant: "blue"

$ contiv-compose up -d
```

3\. Examine the compositions:

```
$ docker inspect example_web_1 | grep \"IPAddress\"
        "IPAddress": "",
                "IPAddress": "10.11.2.6",

$ docker inspect example_redis_1 | grep \"IPAddress\"
        "IPAddress": "",
                "IPAddress": "10.11.2.5",

```

Note that the allocated an IP address from the `blue` tenant's IP pool.

### 7. Done playing with it all - Clean up
Exit the VM and use the following command to destroy the VMs crated for this tutorial

```
$ vagrant destroy -f
```


### Some Notes and Comments

- The demonstrations on this page use the Vagrant utility to set up a VM environment. This environment is for demonstrating automation and integration with Contiv Networking and is not meant to be used in production.
- User-based authentication uses the operational policy in `ops.json` as Docker's authorization
plugin, to permit only authenticated users to specify certain operations.
- Contributing to or Modifying Contiv's *libcompose* variant is welcome! Please make run unit and sanity tests before
submitting a pull request. Running `make test-deploy` and 'make test-unit` from the repository should be sufficient. 

