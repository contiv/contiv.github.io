# Installation Steps

The following installation steps refers to Contiv version 1.0.1.


* Go to your own directory

`$ cd` 

* Download Contiv 1.0.1 package

`$ curl -L -O https://github.com/contiv/install/releases/download/1.0.1/contiv-1.0.1.tgz`

* Untar the package

`$ tar oxf contiv-1.0.1.tgz`

* Enter Contiv directory

`$ cd contiv-1.0.1`

* Start the installation process, make sure to replace "master_private_ip" with the private IP of the machine on which Contiv is running. If you are installing Contiv on a Kubernetes cluster, make sure to install it on the master, in which case replace the "master_private_ip" with the private IP of the Kubernetes master

`$ ./install/k8s/install.sh -n <master_private_ip>`

* Contiv will need some parameters in order to work correctly. At least you will need a network and a gateway.<br />
Configure Contiv in one of the two following way:<br /><br />
	* Use Contiv UI
	
		Open the browser and go to

		`https:///<master_private_ip>:10000`

		make sure to replace <master_private_ip> with the private IP on which you install Contiv. Use the following credentials to log in

		`username: admin`<br />
		`password: admin`

* use the following command to create a network called default-net
 
	`$ netctl net create -t default --subnet=20.1.1.0/24 -g 20.1.1.1 default-net`
	
### Note:
If you are installing Contiv on Kubernetes, make sure to install it as soon as you are done with the initialization of the master. Make sure to initialize the master with the following command

`kubeadm init --service-cidr 10.254.0.0/16`

Remember to install Contiv before joining the cluster with the mionions.
