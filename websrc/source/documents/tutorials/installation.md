1. curl -L -O https://github.com/contiv/install/releases/download/1.0.0/contiv-1.0.0.tgz


2. tar oxf contiv-1.0.0.tgz

3. cd contiv
./install/k8s/install.sh -n <MASTER_PRIVATE_IP>

4. run UI on https://172.31.31.30:10000 admin/C10udCmt5
and follow steps illustrated on screenshot on this local directory
	OR use netctl net create -t default --subnet=20.1.1.0/24 default-net 
	OR IF USING CONTIV 1.0.0-1.0.1 USE netctl net create -t default --subnet=20.1.1.0/24 -g 20.1.1.1 default-net 
	since we need a gateway (-g) to get the DNS working properly.