#!/usr/bin/env bash
set -Eeuxo pipefail

# Install RStudio Server.
# https://www.rstudio.com/products/rstudio/download-server/

build_dir="/tmp/build/rstudio-server"
version="1.2.1335"

echo "Installing RStudio Server ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=/dev/null
. "${script_dir}/_init.sh"

(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"
    wget "https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-${version}-x86_64.rpm"
    sudo yum install -y "rstudio-server-rhel-${version}-x86_64.rpm"
    rm -rf "$build_dir"
)

echo "rstudio-server installed successfully."
command -v rstudio-server
rstudio-server version
rstudio-server status
