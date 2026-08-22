#!/bin/bash

# we are creating 50gb root disk, but only 20gb is partitioned 
# remaining 30gb we need to extend using below commands 
growpart /dev/nvme0n1 4
lvextend -r -L+30G /dev/mapper/RootVG-homeVol
xfs_growfs /home

yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform