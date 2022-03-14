#!/bin/bash

# Download the binary from the Azure Storage Cluster:
wget -O qualys-cloud-agent.x86_64.rpm "https://azrgcnceqbnpbinst.blob.core.windows.net/qualys/qualys-cloud-agent.x86_64.rpm?sp=rl&st=2021-02-18T18:11:01Z&se=2022-02-19T18:11:00Z&sv=2020-02-10&sr=b&sig=ANUuy0bmlDwwK0xiZNW9aIrq32i76J%2BC6%2BcFO3KfTPc%3D"

# Install the binary:
sudo rpm -ivh qualys-cloud-agent.x86_64.rpm 

# Associate the Qualys agent with the Qualys Management Console:
sudo /opt/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=00efd15a-2e57-4144-b909-27c30861a329 CustomerId=0cb7051c-fad2-fc12-8033-bda23989997f 

# I dont know about this one - why would it be in a different folder and what does failure look like
# Can add an 'if' above to look for folder
# (or try this if it fails) Associate the Qualys agent with the Qualys Management Console:
# sudo /usr/local/qualys/qualys-cloud-agent.sh ActivationId=00efd15a-2e57-4144-b909-27c30861a329 CustomerId=0cb7051c-fad2-fc12-8033-bda23989997f 
