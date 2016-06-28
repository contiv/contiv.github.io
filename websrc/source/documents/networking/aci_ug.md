---
layout: "documents"
page_title: "Physical network integration"
sidebar_current: "networking-physical-bgp"
description: |-
  Physical network integration
---

# Contiv in ACI mode

When configured in ACI mode, Contiv utilizes ACI features for policy enforcement and connectivity, while retaining a consistent interface with the container eco-system. In this mode, Contiv interacts with the APIC via an aci-gw in order to create the necessary objects and associations that allows containers to communicate according to the policy intent.

### Configuration

Configuration in ACI mode can be split into the following three categories:

	1. Network resource allocation for Contiv cluster
	2. External policy configuration
	3. Application policy configuration

## Network resource allocation for Contiv cluster

Contiv uses the static VLAN binding mechanism for integrating with ACI. This mechanism requires a physDom, VLAN pool and some associated objects. For a step by step procedure on this configuration refer to [here](/documents/gettingStarted/networking/aci.html)

After the ACI is configured as described above, Contiv must be configured to operate in ACI mode using the netctl command as below.

```
netctl global set --fabric-mode aci --vlan-range 400-500
```

The above example uses a vlan range of 400-500. This must match the VLAN pool you created in APIC.

## External policy configuration

External policy configuration determines how containers in the cluster communicate with endpoints that are outside the container cluster. These endpoints may include Virtual Machines, Physical Servers or endpoints external to the fabric itself. The main ACI objects of interest from this perspective are: Tenant, BD and Contracts.

### Tenant configuration

In most scenarios, the ACI admin would want to pre-create a tenant in the APIC. This allows the tenant to span the container cluster as well as other network endpoints. Tenants are identified by their name in both ACI and Contiv. In order to refer to a tenant that exists in ACI, you can create the same tenant in Contiv using its GUI.

e.g.

```
netctl tenant create MixedTenant
```

If the tenant does not already exist in ACI, it will be created for you when an app-profile is pushed to the ACI as described further down in this doc.

### BD configuration

Contiv does not have an explicit Bridge Domain(BD) object. Because ACI requires a BD object, the aci-gw creates it in ACI when a network is associated with ACI via an app profile binding. However, some use cases might require binding to a BD that already exists in ACI. To bind with an existing BD, the BD's DN must be passed to the aci-gw via the `APIC_EPG_BRIDGE_DOMAIN` environment variable while the aci-gw is started (see <documents/gettingStarted/networking/aci.html>).

### Contracts

For communication between the Contiv cluster and external endpoints, corresponding contracts are necessary. These contracts must be pre-created in ACI and then, their DN must be supplied to Contiv by creating an external-contracts object in Contiv.

e.g.

```
netctl external-contracts  create -t MixedTenant -c -a "uni/tn-MixedTenant/brc-allowicmp" ToConsume
netctl external-contracts  create -t MixedTenant -p -a "uni/tn-MixedTenant/brc-allowicmp" -a "uni/tn-MixedTenant/brc-allowtcp8080" ToProvide
```

An external-contracts object in Contiv contains a set of contracts that can be either consumed or provided by a container application. In the above example, *ToConsume* specifies a contract that can be consumed by an application tier and *ToProvide* specifies a set of contracts that must be provided by an application tier. Application tiers are specified by **groups** (equivalent to EPGs in ACI) within Contiv. A set of external contracts can be associated with a **group** using the netctl group create command.

e.g.

```
netctl group create -t MixedTenant -e ToConsume net1 QueryApp
```

## Application policy configuration

Contiv uses a Group Based Policy like ACI. Each of the application tiers need an endpoint group, associated with a network before policy can be applied to it.

### Create network

A network is created using the netctl command.
E.g.

```
netctl net create -t MixedTenant -e vlan -s 66.1.1.0/24 -g 66.1.1.254 net1
```

Contiv uses the network object for allocating IP addresses to containers. Therefore, even if you're pre-creating a BD, you must still create a network object. If you would like to reserve a part of the subnet for allocation to external endpoints, you can provide a part of the subnet to Contiv.

E.g.

```
netctl net create -t MixedTenant -e vlan -s 66.1.1.20-44/24 -g 66.1.1.254 net1
```

If you pre-created the BD, you must make sure the -g argument matches the BD's gateway.

# Create policy

In order to apply policy, you must create a policy object. You can add rules to the policy after EndpointGroups are created.

```
netctl policy create -t MixedTenant app2db
```

# Create EndpointGroups

Depending on the composition of the application, one more Endpoint Groups must be created in Contiv. Typically, you want to create an Endpoint Group for each of the tiers of the application.

e.g.

```
netctl group create -t MixedTenant -p app2db net1 db
netctl group create -t MixedTenant -e ToConsume -e ToProvide -p app2db net1 app
```

In the example above, db tier specifies just an internal policy. The app tier specifies a set of external contracts in addition to the internal policy.

# Add rules to the policy

You can specify policy between tiers by adding rules to the policy you created. You can add multiple rules to the same policy.

e.g.

```
netctl policy rule-add -t MixedTenant -d in --protocol tcp --port 6379 --from-group app --action allow app2db 1
```

The above rule opens TCP port 6379 from app to db.

# Create an Application Profile

The Application Profile is the point of policy integration between Contiv and ACI. It is when an Application Profile is created that the corresponding objects get pushed to ACI.

```
netctl app-profile create -t MixedTenant -g app,db container-profile
```

The above command will result in application profile being created under MixedTenant in the ACI, with EPG's app and db. There will also be all associated policy objects created.

### Create containers

You can now use docker commands (or other orchestration tools) to create containers. If using docker, use the --net option to specify the docker network name that corresponds to the application tier (use *docker network ls | grep app* to find the network name that corresponds to app in the example). If using kubernetes, you need to specify the tenant, network and endpoint group using the **io.contiv.tenant**, **io.contiv.network** and **io.contiv.net-group** labels respectively.
