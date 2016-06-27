---
layout: "documents"
page_title: "Networking Policies"
sidebar_current: "networking-policies"
description: |-
  Networking Policies
---

## Network Policies

Network policies can help describe rules for network resource usage,
isolation rules, prioritization behavior, etc. on a group of containers.

### Network Isolation Policies

Network Isolation Policies allows white-list or black-list access control rules
to or from an application. It is particularly useful in securing an application
tier. A group on which an inbound policy is applied could be a service tier or
some other logical collection of containers that are required to become part of
a policy domain.

A policy can be manipulated (CRUD) using the following CLI (or an equivalent REST API)
on the `policy` object.

#### Creating a network isolation policy
A policy can be created using `create` operation on `policy` object. During creation of
the policy it must be supplied with a unique name in the `tenant` namespace.

```
$ netctl policy create web-policy
```
The above example will create a policy name `web-policy`. A network isolation policy
can have ACL(access control lists) style white-list or black-list rules. A policy rule
can specify following information:

- `match criteria`: specified using `protocol` and optionally a `port`. If a match
criteria is not specified the rule matches all traffic, or if only `protocol` is
specified but `port` is omitted, then the traffic matches all ports
	. `protocol`: a layer3 (ip, icmp) or layer4 (tcp, udp)
	. `port`: a tcp or udp port number to/from which traffic needs to be permitted/denied
  . `ip-address`: it can specify a masked IP address pool, which can be used to specify
a rules to/from the address pool. It is often useful to specify these rules to/from
non-container workloads
- `direction`: direction can be `inbound` or `outbound`. Semantically direction is
inbound or outbound from container application's point of view. An `inbound` rule
is applicable for the traffic going towards the containers, whereas `outbound` rule
is applicable for the traffic going out from the container.
- `action`: a `permit` or a `deny` action on the traffic that matches the rule. A
white-list set of rules are typically a set of `permit` action followed by a `deny`
the rest.
- `priority`: this allows rules to be ordered and provides a predictable behavior
for a set of arbitrary rules.
- `from-group`: this can be used to `permit` or `deny` traffic to/from a
specific group of containers, identified as a group

For example, if a policy rule needs to specify an inbound set of rules that allows
`tcp/80` and `tcp/443` and deny rest of the traffic, the commands can look like:

```
netctl policy rule-add web-policy 1 -direction=in -protocol=tcp -action=deny
netctl policy rule-add web-policy 2 -direction=in -protocol=tcp -port=80 -action=allow -priority=10
netctl policy rule-add web-policy 3 -direction=in -protocol=tcp -port=443 -action=allow -priority=10
```
#### Associating a network isolation policy to a group
After having define a security policy like mentioned above, one can associate it
with a group to an existing network `contiv-net` as follows:

```
netctl group create contiv-net web-group -policy=web-policy
```

The way to run containers to be associated with `web-group` is done as follows:

- Docker/Swarm:

```
docker run -itd --net=web-group alpine /bin/sh
```
- Kubernetes: specify group association as a label `io.contiv.net-group`
For example in a service (or pod) spec, it could look like:

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: prod-web
spec:
  replicas: 2
  selector:
    app: prod-web
  template:
    metadata:
      labels:
        app: prod-web
        io.contiv.net-group: web-group
    spec:
      containers:
      - name: prod-web
        image: alpine
        command:
          - /bin/sh
```

Kubernetes offers richer option for selection criteria because of `selector` concept,
which can allow arbitrary collection of lables to to be selected to form a dynamic
`group`. For example a collection of {'prod', 'web'} can be an implicit group, where
as {'stage', 'db', 'low-latency'} can be another implicit group. To use this feature
Kubernete's native policy object must be used, available in Kubernetes 1.3 release onwards.

#### Reading, Updating, and Deleting an network isolation policy
`netctl` or equivalent REST APIs can be used to perform other operations on the policy.
For example to list all the policies we can use

```
$ netctl policy ls
Tenant   Policy
------   ------
default  web-policy

```
And to list all the rules in the policy, we can use:

```
$ netctl policy rule-ls web-policy
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1                                                           tcp       0     deny
2     10                                                          tcp       80    allow
3     10                                                          tcp       443   allow
Outgoing Rules:

```

In order to add a new rule to an existing policy, we can use:

```
$ netctl policy rule-add web-policy 4 -direction=in -protocol=tcp -port=8080 -action=allow -priority 10

$ netctl policy rule-ls web-policy
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1                                                           tcp       0     deny
3     10                                                          tcp       443   allow
4     10                                                          tcp       8080  allow
2     10                                                          tcp       80    allow
Outgoing Rules:
Rule  Priority  To EndpointGroup  To Network  To IpAddress  Protocol  Port  Action
----  --------  ----------------  ----------  ---------     --------  ----  ------

```
Or to delete an existing rule we can use the `rule-id` specified in the `rule-delete`
command:

```
netctl policy rule-rm web-policy 4
```

Finally, to delete a policy, we can use `delete` verb on the policy:

```
netctl policy delete web-policy
```

#### Deleting, Updating a group
`netctl` or equivalen REST APIs can be use to perform CRUD operations on `group` object.
For example to delete a group, we can use:

```
netctl group delete web-group
```
Note however that above command would fail if there are containers belonging to the
group, or if there are policies associated with the group. Therefore one must delete
various containers and policies associated with the group before deleting a group.

Updating a group to use a different policy can be done using the `create` verb:

```
netctl group create contiv-net web-group -policy=new-web-policy
```

#### Associating multiple policies to a group
The policy system is dynamic with respect to:

- Rules are expected to be altered after the policy is defined
- Policy association to a group of containers can be added or removed as desired
In the above section we observed how rules can be added and deleted to an existing policy.
This section we will examine specifying a category of rules to be defined as atomic
units of policies that can be manipulated and applied across a group of containers
in a flexible manner, and also be updated after the group is defined and created.

Say we crate a `staging-web-group` that is expected to open up not only the web ports
but also some ports for diagnostics purposes. For this use case we can define two policies
called `allow-web` and `allow-diags` as follows:

```
$ netctl policy create allow-web
$ netctl policy rule-add allow-web 1 -direction=in -protocol=tcp -action=deny
$ netctl policy rule-add allow-web 2 -direction=in -protocol=tcp -port=80 -action=allow -priority=10
$ netctl policy rule-add allow-web 3 -direction=in -protocol=tcp -port=443 -action=allow -priority=10
$ netctl policy rule-ls allow-web
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1                                                           tcp       0     deny
2     10                                                          tcp       80    allow
3     10                                                          tcp       443   allow

$ netctl policy create allow-diags
$ netctl policy rule-add allow-diags 1 -direction=in -protocol=icmp -action=allow
$ netctl policy rule-ls allow-diags
Incoming Rules:
Rule  Priority  From EndpointGroup  From Network  From IpAddress  Protocol  Port  Action
----  --------  ------------------  ------------  ---------       --------  ----  ------
1     1                                                           icmp      0     allow
```

Now we can associate both of these policies to a group we are calling `staging-web-group`
using:

```
$ netctl group create contiv-net stage-web-group -policy=web-policy -policy=allow-diags

$ netctl group ls
Tenant   Group            Network     Policies
------   -----            -------     --------
default  stage-web-group  contiv-net  web-policy,allow-diags
```

At this point we can run a container that belongs to `stage-web-group` as following and
can expect a combination of the policies be applied towards any traffic to the container(s)

```
$ docker run -itd --net=stage-web-group --name=c1 alpine /bin/sh
```

And if we decide to withdraw the allow-diags policy, all rules corresponding to the policy
will be withdrawn automatically. The withdrawl of a policy is done by providing the updated
list of new policies associated with a group, for example:

```
$ netctl group create contiv-net stage-web-group -policy=web-policy
$ netctl group ls
Tenant   Group            Network     Policies
------   -----            -------     --------
default  stage-web-group  contiv-net  web-policy
```

#### Associating a policy to multiple groups
A policy can be applied to multiple groups i.e. policy is reusable across groups.
For example `allow-diags` can be used by `dev-web-group` or `staging-web-group` both
as follows:

```
$ netctl group create contiv-net dev-web-group -policy=allow-diags
$ netctl group ls
Tenant   Group            Network     Policies
------   -----            -------     --------
default  stage-web-group  contiv-net  web-policy,allow-diags
default  dev-web-group    contiv-net  allow-diags
```

Any update to the policy rules, will be applied to all the groups a policy is associated with. This allows a structured way of creating a block of policies that can be reused, reassigned
and repurposed dynamically.



### Network Bandwidth Limiting

Network Bandwidth Policies allows specifying the bandwidth limits on a container
that belongs to a specific group. This policy is useful in limiting the bandwidth
usage by any of the containers belonging to a specific group.

Policies, like network isolation, is applied between two groups, where as other policies
like `network bandwidth` allocation, etc. are applied on a group, or containers within
a group.

A `netwrok-profile` describes various attributes that can be applied to a group, for example
network bandwidth limits. A `network-profile` can be created as follows:

```
$ netctl netprofile create -b 1Mbps -dscp 3 dev-net-profile
Name							Tenant		Bandwidth		DSCP
----							------    ---------		----
dev-net-profile		default		1Mbps				3
```
The above mentioned network profile allows associated containers to be capped with
a network bandwidth of 1Mbps and set their DSCP (Differentiated Services Code Point,
or Type of Service) Bits in the IP header.

After having created a network profile, a profile can be associated with a group.

```
$ netctl group create contiv-net dev-web-group -policy=allow-diags -networkprofile=dev-net-profile
$ netctl group ls
Tenant   Group            Network     Policies							Network Profile
------   -----            -------     --------							---------------
default  stage-web-group  contiv-net  web-policy,allow-diags	default
default  dev-web-group    contiv-net  allow-diags						dev-net-profile
```

At this point all one can expect the bandwidth policy to be in action.

#### Using Traffic Prioritization for network wide application behavior
TL;DR (for networking experts only)
If a physical network is configured with the classes of traffic identified with DSCP, then
a DSCP marking can achieve an end to end application behavior. For example, most of the
physical network switching vendors, like Cisco, provide a way to allow use of network
bandwidth and traffic scheduling based on DSCP. Configuring physical network devices is
out of scope for this document, however it is worth noting that these features provide:

- Bandwidth allocation: specify how much packet buffers (aka buffering) are allocated
to a given class of service (CoS)
- Bandwidth rate lmiting: Rate limiting the traffic belonging to a class, that can specify
the rules of traffic precedence during a bursts or during contention. This can provide
network predictability to classes of traffic
- Traffic Scheduling: Usually the default scheduling policy on a switch is to round-robin
the traffic towards a destination. However in cases of contention, a more sophisticated
prioritized scheduling can be defineed to allow preference to schedule traffic with a
specific DSCP.

The integration of DSCP/prioritization with application can bring a predictable network
behavior for network and/or storage traffic.
