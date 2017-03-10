---
layout: "documents"
page_title: "Physical network integration"
sidebar_current: "networking-physical-bgp"
description: |-
  Physical network integration
---

# Contiv in ACI Mode

Contiv works with Cisco Application Centric Infrastructure (ACI) for policy enforcement and connectivity. At the same time, Contiv maintains a consistent interface with the container ecosystem. Contiv interacts with the APIC via an ACI gateway (ACI-GW) to create the objects and associations that enable containers to communicate according to the policy intent.

![ACI](/assets/images/aci-integration.png)

## UI Configuration

As a Contiv admin, you can set up ACI as your network default.

See [Managing Networks](/documents/admin/manageNetworks.html).

## CLI Configuration

Configuration in ACI mode can be split into the following three categories:

1\. Network resource allocation for your Contiv cluster<br>
2\. External policy configuration<br>
3\. Application policy configuration<br>

### Network Resource Allocation for Your Contiv Cluster

Contiv uses the static VLAN binding mechanism to integrate with ACI. This mechanism requires a physDom, VLAN pool, and some associated objects. For a step-by-step guide to this configuration see [Installing Contiv Network with Cisco ACI].

After the ACI is configured, Contiv must be configured using the `netctl` command as follows:

```
netctl global set --fabric-mode aci --vlan-range 400-500
```

Note: The VLAN range must match the VLAN pool you create in APIC. The range in this example is 400-500.

### External Policy Configuration

External policy configuration determines how containers in the cluster communicate with endpoints that are outside the container cluster. These endpoints may include VMs, physical servers or endpoints external to the fabric itself. The main ACI objects of interest from this perspective are: tenants, bridge domains (BDs), and contracts.

#### Tenant Configuration

In most scenarios, the ACI admin wants to pre-create a tenant in the APIC. This gives the tenant the ability to span the container cluster as well as other network endpoints. Tenants are identified by their name in both ACI and Contiv. In order to refer to a tenant that exists in ACI, you can create the same tenant in Contiv using the Contiv Network CLI.

For example, the following command creates a tenant in Contiv:

```
netctl tenant create MixedTenant
```

If the tenant does not already exist in ACI, it is created for you when an application profile is pushed to the ACI as described below.

#### Bridge Domain Configuration

Contiv does not have an explicit BD object. Because ACI requires a BD object, the ACI-GW creates it in ACI when a network is associated with ACI with an app profile binding. 

Some use cases might require binding to a BD that already exists in ACI. To bind with an existing BD, the BD's domain name (DN) must be passed to the ACI-GW via the `APIC_EPG_BRIDGE_DOMAIN` environment variable when the ACI-GW is started. See [Installing Contiv Network with Cisco ACI].

#### Contracts

For communication between the Contiv cluster and external endpoints, corresponding contracts are necessary. Such a contract must first be created in ACI, then its DN must be supplied to Contiv by creating an external-contracts object in Contiv.

An external-contracts object in Contiv contains a set of contracts that can be either consumed or provided by a container application. 

In the following example, *ToConsume* specifies a contract that can be consumed by an application tier and *ToProvide* specifies a set of contracts that must be provided by an application tier. Application tiers are specified by *groups* (equivalent to EPGs in ACI) within Contiv. 

```
netctl external-contracts  create -t MixedTenant -c -a "uni/tn-MixedTenant/brc-allowicmp" ToConsume
netctl external-contracts  create -t MixedTenant -p -a "uni/tn-MixedTenant/brc-allowicmp" -a "uni/tn-MixedTenant/brc-allowtcp8080" ToProvide
```

A set of external contracts can be associated with a group using the netctl group create command:

```
netctl group create -t MixedTenant -e ToConsume net1 QueryApp
```

### Application Policy Configuration

Contiv uses a group-based policy like ACI. Each of the application tiers must have an endpoint group associated with a network before policy can be applied to it.

#### Create a Network

You create a network using the `netctl` command:

```
netctl net create -t MixedTenant -e vlan -s 66.1.1.0/24 -g 66.1.1.254 net1
```

Contiv uses the network object to allocate IP addresses to containers. Therefore, even if you pre-create a BD, you must still create a network object. If you would like to reserve a part of the subnet for allocation to external endpoints, you can provide part of the subnet to Contiv.

For example:

```
netctl net create -t MixedTenant -e vlan -s 66.1.1.20-44/24 -g 66.1.1.254 net1
```

If you pre-created the BD, the `-g` argument matches the BD's gateway.

#### Create a Policy

To apply a policy, create a policy object. You can add rules to the policy after EPGs are created.

```
netctl policy create -t MixedTenant app2db
```

#### Create Endpoint Groups

Depending on the composition of the application, one more EPG must be created in Contiv. Typically, you create an EPG for each tier of the application.

In the following example , the *db* tier specifies only an internal policy. The *app* tier specifies a set of external contracts in addition to the internal policy.

```
netctl group create -t MixedTenant -p app2db net1 db
netctl group create -t MixedTenant -e ToConsume -e ToProvide -p app2db net1 app
```

#### Add Rules to the Policy

Specify policy between tiers by adding rules to the policy you created. You can add multiple rules to the same policy.

For example, the following rule opens TCP port 6379 from *app* to *db*.

```
netctl policy rule-add -t MixedTenant -d in --protocol tcp --port 6379 --from-group app --action allow app2db 1
```

#### Create an Application Profile

The application profile is the point of policy integration between Contiv and ACI. It is when an application profile is created that the corresponding objects get pushed to ACI.

The following command results in an application profile being created under MixedTenant in the ACI with EPGs `app` and `db`. All associated policy objects are also created.

```
netctl app-profile create -t MixedTenant -g app,db container-profile
```

### Create Containers

You can now use Docker commands (or other orchestration tools) to create containers. If you are using Docker, use the `--net` option to specify the Docker network name that corresponds to the application tier (use `docker network ls | grep app` to find the network name that corresponds to `app` in the example). For Kubernetes, specify the tenant, network, and endpoint group using the `io.contiv.tenant`, `io.contiv.network`, and `io.contiv.net-group` labels respectively.

[Installing Contiv Network with Cisco ACI]: </documents/gettingStarted/networking/aci.html>
