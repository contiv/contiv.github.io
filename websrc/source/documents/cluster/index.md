---
layout: "documents"
page_title: "Cluster"
sidebar_current: "cluster"
description: |-
  Cluster
---

# Contiv Cluster

## Overview

Contiv Cluster is an integrated collection of software components that simplifies deployment, management, and maintenance
of clustering systems. At the heart of Contiv Cluster is Cluster Manager, a RESTful API service providing
programmatic access to Contiv Cluster.

Contiv Cluster is designed to support a range of clustering software such as Docker Swarm, Kubernetes,
Apache Mesos, and others. Currently, Contiv Cluster supports the following cluster-related products:

- *Cluster Type*: Docker [Unified Control Plane]
https://www.docker.com/products/docker-universal-control-plane) and Docker [Swarm](https://docs.docker.com/swarm/)
- *Cluster OS*: [CentOS 7.2](https://www.centos.org/)
- *Cluster Target*: Bare Metal and [Vagrant](https://www.vagrantup.com/)

## More Information

The following sections contain more background information on Contiv Cluster.
- [Concepts and Terminology](/documents/cluster/concepts.html)
- [Node Lifecycle management](/documents/cluster/node-lifecycle.html)
