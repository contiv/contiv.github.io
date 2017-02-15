---
layout: "documents"
page_title: "Service Routing"
sidebar_current: "networking-services"
description: |-
  Service Routing
---

# Service Load Balancing

A service provides network connection on a set of ports to a cluster of  containers matching the service label selector. 

Services offer:

- Easy scaling up and down. 
- Efficient load balancing.
- Minimal downtime.

A provider is one or more containers that match the label selector associated with the services.

## Defining Services

After you create your network, you can define services using the UI, the `netctl` command line interface (CLI), or the Contiv Network REST APIs, but it is recommended
to use the UI or API to take advantage of the authentication and authorization options in those interfaces.

Note: Service requirements are defined by *selectors*. Selectors are key-value pairs 
that group providers with matching labels. 

To create a Service Load Balancer using the UI:

1\. From *Service Load Balancer*, click *Create Service Load Balanacer*. 
![service](CreateServiceLoadBalancer.png)<br>
   The Create Service Load Balancer page displays.<br>
![createservice](CreateServiceLoadBalancer.png)   
2\. Choose a name for the service load balancer. <br>
3\. Select the tenant.<br>
4\. Select the network. <br>
5\. Enter the *Service IP* address.<br>
6\. Under *Label Selectors* choose you label name and value.<br>
7\. Choose your *Service* and *Provider* ports and your *Protocol*.<br>
8\. Click *Create*.<br>


To create a Service Load Balancer, using the CLI, run:

```
netctl net create [$SERVICE_NAME] -s [$SERVICE_IP_ADDRESS]

netctl service create [$APP_SERVICE_NAME] --network [$NETWORK_NAME] --tenant [$TENANT_NAME] selector=[$selector1] --selector=[$selector2] --selector=[$selector3] --port [$SERVICE_PORT]:[$PROVIDER_PORT]:[$PROTOCOL]
```

For example, to create a web service in a web tier for which providers must be stable and production-ready:

```
netctl net create contiv-srv-net -s 100.1.1.0/24

netctl service create app-svc --network contiv-srv-net --tenant default --selector=tier=web --selector=release=stable --selector=environment=prod --port 8080:80:TCP
```

<!--## Demonstration of Reachability to a Service from the Client Containers

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
-->