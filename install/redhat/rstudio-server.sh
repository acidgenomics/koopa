#!/usr/bin/env bash
set -Eeuxo pipefail

# Install RStudio Server.
# https://www.rstudio.com/products/rstudio/download-server/

version="1.2.1335"

echo "Installing RStudio Server ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "${script_dir}/_init.sh"

wget "https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-${version}-x86_64.rpm"
sudo yum install -y "rstudio-server-rhel-${version}-x86_64.rpm"

rstudio-server verify-installation

echo "rstudio-server installed successfully."
command -v rstudio-server
rstudio-server version
rstudio-server status
