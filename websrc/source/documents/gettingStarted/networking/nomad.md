---
layout: "documents"
page_title: "Installing Mesos"
sidebar_current: "getting-started-networking-vagrant-nomad"
and description: |-
  Installing Mesos
---

# Contiv Network with Nomad

This page demostrates the simplicity of using Contiv as 
the networking and policy infrastructure for containers using Nomad to schedule 
Docker containers. 

The steps here can be adapted to any Vagrant or bare-metal setups running Contiv components.

## Prerequisites
Before you can install the virtual environment, you must have the following
software packages on your machine:

- VirtualBox 5.0.2 or later
- Vagrant 1.7.4
- Make


## Step 1: Start the Virtual Environment

Use the following commands to clone the Contiv Network [workspace] 
and start the Vagrant envaronment with Nomad installed.

```
$ git clone https://github.com/contiv/netplugin
$ cd netplugin; make nomad-docker
$ vagrant ssh netplugin-node1
```

## Step 2: Create Client and Server Configuration File

Open the client and server configuration files for the Nomad 
client and server agents. 

In this demo the Nomad server and client agents are running on 
`netplugin-node1` and a client agent is running on `netplugin-node2`.

The `client1.hcl` file should look like the following:

```
# Increase log verbosity
log_level = "DEBUG"         

# Setup data dir
data_dir = "/tmp/client1"

enable_debug = true
bind_addr = "192.168.2.10"

addresses {
    rpc = "192.168.2.10"
    http = "192.168.2.10"
    serf = "192.168.2.10"
}

advertise {
# We need to specify our host's IP because we can't
# advertise 0.0.0.0 to other nodes in our cluster.

    rpc = "192.168.2.10:5647"
    http = "192.168.2.10:5646"
    serf = "192.168.2.10:5648"
}


# Enable the client
client {
    enabled = true

    # For demo assume we are talking to server1. For production,
    # this should be like "nomad.service.consul:4647" and a system
    # like Consul used for service discovery.
    servers = ["192.168.2.10:4647"]
    node_class = "foo"
    options {
        "driver.raw_exec.enable" = "1"
    }

    reserved {
       cpu = 300
       memory = 301
       disk = 302
       iops = 303
       reserved_ports = "1-3,80,81-83"
    }
}

# Modify our port to avoid a collision with server1
ports {
    http = 5646
    rpc = 5647
    serf = 5648
}
```

The `server.hcl` file should look like the following:

```
# Increase log verbosity
log_level = "DEBUG"

bind_addr = "192.168.2.10"

addresses {
  rpc = "192.168.2.10"
  http = "192.168.2.10"
  serf = "192.168.2.10"
}

advertise {
  # We need to specify our host's IP because we can't
  # advertise 0.0.0.0 to other nodes in our cluster.
  rpc = "192.168.2.10:4647"
  http = "192.168.2.10:4646"
  serf = "192.168.2.10:4648"
}

# Setup data dir
data_dir = "/tmp/server1"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}

ports {
    http = 4646
    rpc = 4647
    serf = 4648
}

```

The `client2.hcl` file should look like the following:

```
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/client1"

enable_debug = true
bind_addr = "192.168.2.11"

addresses {
    rpc = "192.168.2.11"
    http = "192.168.2.11"
    serf = "192.168.2.11"
}

advertise {
# We need to specify our host's IP because we can't
# advertise 0.0.0.0 to other nodes in our cluster.

    rpc = "192.168.2.11:4647"
    http = "192.168.2.11:4646"
    serf = "192.168.2.11:4648"
}


# Enable the client
client {
    enabled = true

    # For demo assume we are talking to server1. For production,
    # this should be like "nomad.service.consul:4647" and a system
    # like Consul used for service discovery.
    servers = ["192.168.2.10:4647"]
    node_class = "foo"
    options {
        "driver.raw_exec.enable" = "1"
    }

    reserved {
       cpu = 300
       memory = 301
       disk = 302
       iops = 303
       reserved_ports = "1-3,80,81-83"
    }
}

# Modify our port to avoid a collision with server1
ports {
    http = 4646
    rpc = 4647
    serf = 4648
}
```

Use the following commands to log into `netplugin-node1` and start
the Nomad client and server agents:

```
$vagrant ssh netplugin-node1
vagrant@netplugin-node1$ nomad agent -config server.hcl &
vagrant@netplugin-node1$ nomad agent -config client1.hcl &
```

In a different shell window, log into `netplugin-node2` and start the
Nomad client:

```
vagrant ssh netplugin-node2
vagrant@netplugin-node2$ nomad agent -config client2.hcl &
```

## Step 3: Verify the Node Status 
Use the following command to ensure the nodes have been discovered and peered:

```
vagrant@netplugin-node1:/tmp$ nomad node-status -address=http://192.168.2.10:4646
    2016/03/16 17:51:11 [DEBUG] http: Request /v1/nodes (101.494µs)
ID        Datacenter  Name             Class  Drain  Status
8cd0aaa1  dc1         netplugin-node2  foo    false  ready
4bac61f9  dc1         netplugin-node1  foo    false  ready
```

##Step 4: Create a Network 
Next, create a network and attach it to an endpoint group (EPG).

If an EPG has to be attached to a network - create policies and attach rules to the same. . Refer to the [Contiv docs] on steps to create policies.  

The following commands create the following entities:

- A network called `contiv-net`
- A policy call `prod_web`
- An EPG called `web`

The policy is associated with the EPG, and the EPG is attached to the network.
The policy has three rules, one to deny all incoming TCP connections and two to create exceptions on ports 80 and 443.

```
vagrant@netplugin-node1: netctl net create contiv-net -subnet="40.1.1.0/24"
vagrant@netplugin-node1: netctl policy create prod_web
vagrant@netplugin-node1: netctl policy rule-add prod_web 1 -direction=in -protocol=tcp -action=deny
vagrant@netplugin-node1: netctl policy rule-add prod_web 2 -direction=in -protocol=tcp -port=80 -action=allow -priority=10
vagrant@netplugin-node1: netctl policy rule-add prod_web 3 -direction=in -protocol=tcp -port=443 -action=allow -priority=10
vagrant@netplugin-node1: netctl group create contiv-net web -policy=prod_web

```

## Step 5: Schedule Tasks

Now that infrastructure is set up, create a job file to schedule tasks:

```
vagrant@netplugin-node1:~$ nomad init
```

This creates a file called `example.nomad` that deploys containers in a network. 
Change the Docker driver configuration in the file to specify a network to attach containers to. 
If the network has an EPG (and thus a policy) attached to it, then the format for the network name is `<epgname>.<network>`. 
To attach the container to a network with policies, set the `network_mode` to `network_name`.

The following file, `example.nomad`, illustrates a configuration with an EPG:

```
              # Use Docker to run the task.
                        driver = "docker"

                        # Configure Docker driver with the image
                        config {
                                image = "redis:latest"
                                port_map {
                                        db = 6379
                                }
                                network_mode="web.contiv-net"
                        }
```

Finally, use this command to start the task: 

```
vagrant@netplugin-node1:~$ nomad run -address=http://192.168.2.10:4646 example.nomad
```

## Step 6: Verify the EPGs

On node 2, use the following command to verify that the endpoints for containers are allocated 
IP addresses from the network you created:

```
vagrant@netplugin-node2:~$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                  NAMES
5d5522b9ae0a        redis:latest        "/entrypoint.sh redis"   28 seconds ago      Up 26 seconds       10.0.2.15:58847->6379/tcp, 10.0.2.15:58847->6379/udp   redis-5d46fa82-fcc4-53cc-cf08-059417217e59
```

List the networks:

```
vagrant@netplugin-node1:/tmp$ docker network ls
NETWORK ID          NAME                DRIVER
0c242226aa20        web.contiv-net      netplugin           
222c44a4380b        contiv-net          netplugin           
f28f834efacf        bridge              bridge              
fc1f63732ca8        none                null                
a4f246e21bb9        host                host
```

View the network details with the following command:

```
vagrant@netplugin-node2:~$ docker network inspect web.contiv-net
[
    {
        "Name": "web.contiv-net",
        "Id": "0c242226aa20bfb693d6fda89f7eb6ca3f68909b056d6178a4d9c7186c5942ed",
        "Scope": "global",
        "Driver": "netplugin",
        "IPAM": {
            "Driver": "netplugin",
            "Config": [
                {
                    "Subnet": "40.1.1.0/24"
                }
            ]
        },
        "Containers": {
            "5d5522b9ae0a257707eecf05ff5beb6ee939a9c34b85254134ea0a3197427c1f": {
                "EndpointID": "256aadcb73b1b96ce690d69d2fb044aef89f19b3dd8325242958fbb44b1ec4e8",
                "MacAddress": "",
                "IPv4Address": "40.1.1.4/24",
                "IPv6Address": ""
            }
        },
        "Options": {
            "encap": "vxlan",
            "pkt-tag": "1",
            "tenant": "default"
        }
    }
]
```

View a container by copying its ID from the network information:

```
vagrant@netplugin-node2:/tmp$ docker inspect 5d5522b9ae0a

        "Networks": {
            "web.contiv-net": {
                "EndpointID": "256aadcb73b1b96ce690d69d2fb044aef89f19b3dd8325242958fbb44b1ec4e8",
                "Gateway": "",
                "IPAddress": "40.1.1.4",
                "IPPrefixLen": 24,
                "IPv6Gateway": "",
                "GlobalIPv6Address": "",
                "GlobalIPv6PrefixLen": 0,
                "MacAddress": ""
            }
        }
    }
}
]
```

[workspace]: <https://github.com/contiv/netplugin>
[Contiv docs]: <http://contiv.github.io/docs/3_netplugin.html>
