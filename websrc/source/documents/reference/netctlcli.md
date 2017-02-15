---
layout: "documents"
page_title: "CLI Reference for netctl"
sidebar_current: "reference"
description: |-
  netctl
---

#Command-Line Interface
Contiv uses the netctl command-line interface (CLI) to configure networks, policies, and service load balancers.

##USAGE:
   `./netctl [global options] command [command options] [arguments...]`
   
##COMMANDS:<br>
   `version`  Version Information<br>
   `group` Endpoint Group 
   manipulation 		tools<br>
   `endpoint, ep`  Endpoint Inspection<br>
   `netprofile`		Network profile manipulation tools <br>
   `network, net` Network manipulation tools <br>
   `tenant` Tenant manipulation tools <br>
   `policy` Policy manipulation tools <br>
   `external-contracts` External contracts <br>
   `global`	Global information <br>
   `aci-gw`	 ACI Gateway information <br>
   `bgp`	Router capability configuration</br>
   `app-profile` Application Profile manipulation tools <br>
   `service` Service object creation<br>
   `help, h` Shows a list of commands or help for one command
   
##GLOBAL OPTIONS:
   `--netmaster "http://netmaster:9999"`	The hostname of the netmaster [$NETMASTER] <br>
   `--help, -h`				show help <br>
   `--version, -v`			print the version <br>
