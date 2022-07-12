# AkashNetworkSetup

Akash Network deployment Script for deploying Shardus Nodes. <br />
The script uses the Deploy file to specify the specs of the VM on which the Shardus application runs. <br />
Since Akash uses Docker containers for the VMs, we forward the port as specified in the Deploy file. We then get back from the node the external port used to access the 
internal port specified in the deploy file.<br />
For testing purposes, the docker image used in the Akash network nodes is a ssh-compatible image which we ssh into to install all the dependencies of the Shardus 
application and specify the configs. <br />
