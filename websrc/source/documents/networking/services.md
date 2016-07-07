---
layout: "documents"
page_title: "Service Routing"
sidebar_current: "networking-services"
description: |-
  Service Routing
---

# Service Loadbalancing

This page describes the implementation of service loadblancer support for Docker.

## What is a Service? 


A service is an abstraction providing a network connection on a set of ports to a cluster of 
containers matching the service label selector. 
Services have several advantages. They:

- Are easy to scale up and down. 
- Provide for efficient loadbalancing.
- Result in minimal downtime.

## What are Providers for a Service?

A provider is one or more containers that match the label selector associated with the services.

## How is a Service Defined?

Services are defined using the `netctl` command line interface (CLI) or the Contiv Network Rest APIs. 
Services must be created in an existing service network, so you first create a service network, then attach 
the service. Requirements for services are defined in the form of *selectors*. Selectors are key-value pairs 
that group providers with matching labels. 

The following example shows the creation of a web service in a 
web tier for which providers must be stable and production-ready:

```
netctl net create contiv-srv-net -s 100.1.1.0/24

netctl service create app-svc --network contiv-srv-net --tenant default --selector=tier=web --selector=release=stable --selector=environment=prod --port 8080:80:TCP
```

## How to Add Providers to a Service

Providers are associated with a service by starting the containers with matching labels. 

The following example shows the creation of a network called `contiv-net` which is used by the four providers created with labels matching the service selector:

```
netctl net create contiv-net -s 10.1.1.0/24 -g 10.1.1.254

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
2c30b978c87bad64ced1f8158b72d17abf7748889464023d4e23a4bd24ae2d28

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
3a23aa2d5891153999871544362b881fcd461e46021007453e0e6e7edf06b348

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
ef6691ebb26ea54749242606ec23be01903f886f58382e346ec61369aab39073

docker run -itd --net=contiv-net --label=tier=web --label=release=stable --label=environment=prod --label=version=1.0 alpine sh
2a3ac3917e54775081e2afc40ce6d718e7871d4814a6fd387ecf4eca16fc2474

```

## Demonstration of Reachability to a Service from the Client Containers

The followin example uses the *netcat* (`nc`) command to start listeners on each of the providers:

```
docker exec -it 2c30b978c87bad64ced1f8158b72d17abf7748889464023d4e23a4bd24ae2d28 sh
#nc -l -p 80 &

docker exec -it 3a23aa2d5891153999871544362b881fcd461e46021007453e0e6e7edf06b348 sh
#nc -l -p 80 &

docker exec -it ef6691ebb26ea54749242606ec23be01903f886f58382e346ec61369aab39073 sh
#nc -l -p 80 &

docker exec -it 2a3ac3917e54775081e2afc40ce6d718e7871d4814a6fd387ecf4eca16fc2474 sh
#nc -l -p 80 &
```

Finally, the following example does three things:

- Creates a network for a client (consumer of the service). 
- Starts the client container. 
- Uses netcat to attempt to reach the service IP (service IP allocated in our example is 100.1.1.3) on the service port.

```
netctl net create client-net -s 11.1.1.0/24 -g 11.1.1.254

docker run -itd --net=client-net  alpine sh
9e6842a59369ba67d6224c1502ab0e68360fe7aaa0949a04462a9ae0bdbc6830

docker exec -it 9e6842a59369ba67d6224c1502ab0e68360fe7aaa0949a04462a9ae0bdbc6830 sh
# nc -znvw 1 100.1.1.3 8080
100.1.1.3 (100.1.1.3:8080) open
```

*Note*: The service IP can also be a preferred IP address. This can be enforced while creating the service configuration with the `-ip` option.
