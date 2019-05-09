#!/usr/bin/env bash
set -Eeuxo pipefail

# Install RStudio Server.
# https://www.rstudio.com/products/rstudio/download-server/

wget https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-1.2.1335-x86_64.rpm
sudo yum install -y rstudio-server-rhel-1.2.1335-x86_64.rpm
