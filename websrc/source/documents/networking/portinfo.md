---
layout: "documents"
page_title: "Managing Ports"
sidebar_current: "networking-portinfo"
description: |-
  Contiv Ports
---

# Managing Ports

Contiv uses the following ports. Make sure they are open and available in your Contiv-related containers:

| Software   |      Port Number      |  Protocol | Notes |
|----------|:-------------:|------:|:-----------:
| Contiv |  9001 | TCP | Communication between OVS and Contiv |
| Contiv |  9002 | TCP | Communication between OVS and Contiv |
| Contiv |  9003 | TCP | Communication between OVS and Contiv |
| Contiv |  9999 | TCP | Netmaster port |
| BGP Port | 179 | TCP | Contiv in L3 mode will require this |
| VXLAN | 4789 |  UDP | Contiv in VXLAN network will use this port |
| Docker API | 2385 |  TCP | Docker related |
| Docker Swarm | 2375 |  TCP | Docker swarm related |
| Consul | 8300 |  TCP,UDP | Consul KV store related |
| Consul | 8301 |  TCP,UDP | Consul KV store related |
| Consul | 8500 |  TCP,UDP | Consul KV store related |
| Consul | 8400 |  TCP,UDP | Consul KV store related |
| etcd | 2379 |  TCP | etcd KV store related |
| etcd | 2380 |  TCP | etcd KV store related |
| etcd | 4001 |  TCP | etcd KV store related |
| etcd | 7001 |  TCP | etcd KV store related |
| auth\_proxy | 10000 |  TCP | Contiv auth\_proxy |
