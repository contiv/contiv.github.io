---
layout: "documents"
page_title: "Service Routing"
sidebar_current: "networking-services"
description: |-
  Service Routing
---

# Service Loadbalancing

If you want service load balancing support for Docker, you can configure it using Contiv.

A service is an abstraction providing a network connection on a set of ports to a cluster of 
containers matching the service label selector. 
Services have several advantages:

- Easy to scale 
- Provide for efficient load balancing
- Result in minimal downtime

A service provider is one or more containers with the matching label for those services.

## Defining Services

After you have created service networks for Contiv, you can define a service in the UI, using the `netctl` command line interface (CLI), or with the Contiv Network REST APIs. Services must be able to attach to an existing network. 

Services require *selectors*. Selectors are key-value pairs that group providers with matching labels. Without a selector, a service cannot run in a container.

To define a service using the UI:

1. 
2.
3.

To define a service in the CLI:

1. Run netctl and use the *net create* command to define your service network:
   For example:
```
   netctl net create contiv-srv-net -s 100.1.1.0/24

```   
2. Run netctl and create a service attached to your network. Choose your selectors

For example, this command creates a network with 
```
netctl service create app-svc --network contiv-srv-net --tenant default --selector=tier=web --selector=release=stable --selector=environment=prod --port 8080:80:TCP
```
3.



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

## Reaching a Service from the Client Containers

The following example uses the *netcat* (`nc`) command to start listeners on each of the providers:

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
