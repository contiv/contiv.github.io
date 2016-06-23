---
layout: "documents"
page_title: "Cluster"
sidebar_current: "cluster"
description: |-
  Cluster
---

# Contiv Cluster

##Overview
Contiv Cluster is an integrated collection of software that simplifies deployment, management, and maintenance
of clustering systems. At the heart of Contiv Cluster is Cluster Manager, a RESTful API service providing
programmatic access to the Contiv Cluster.

Contiv Cluster intends on supporting a range of clustering software such as Docker Swarm, Kubernetes,
Apache Mesos, and others. Currently, Contiv Cluster supports the following cluster formation:

* **Cluster Type**: Docker [Unified Control Plane]
(https://www.docker.com/products/docker-universal-control-plane) | Docker [Swarm](https://docs.docker.com/swarm/)
* **Cluster OS**: [CentOS 7.2](https://www.centos.org/)
* **Cluster Target**: Bare Metal | [Vagrant](https://www.vagrantup.com/)


## Table of Contents
- [Concepts and Terminology](/documents/cluster/concepts.html)
- [Node Lifecycle management](/documents/cluster/node-lifecycle.html)
