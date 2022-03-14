#!/bin/bash

# Download the binary from the Azure Storage Cluster
wget -O SentinelAgent_linux_v4_3_3_1.rpm "https://azrgcnceqbnpbinst.blob.core.windows.net/sentinelbinaries/SentinelAgent_linux_v4_3_3_1.rpm?sp=rl&st=2021-03-03T04:15:15Z&se=2022-03-04T04:15:00Z&sv=2020-02-10&sr=b&sig=kAc8xvxTHTiwSg5CrGUSaGr4GA64CEYQLIN3En1fEoY%3D"

# Install the binary
sudo rpm -i SentinelAgent_linux_v4_3_3_1.rpm  

#Associate the Sentinel install with the EQ Management Portal: 
sudo /opt/sentinelone/bin/sentinelctl management token set eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMTEuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjM5ZGNlNjlmMzQzMWIzNTYifQ==

#Activate agent on the linux system
sudo /opt/sentinelone/bin/sentinelctl control start

#List UUID
sudo /opt/sentinelone/bin/sentinelctl management uuid get