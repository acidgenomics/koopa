#!/usr/bin/env bash
set -Eeuo pipefail

# This script requires yum.
command -v yum >/dev/null 2>&1 || { echo >&2 "yum missing."; exit 1; }

# Alternatively, here's how to require root user.
# if (( EUID != 0 ))
# then
#     echo "This script must be run as root."
#     exit 1
# fi

sudo -v
log_dir="${HOME}/logs/${HOSTNAME}/yum"
mkdir -p "$log_dir"
log_file="${log_dir}/yum-update-$(date +%F).log"
sudo yum update -y 2>&1 | tee "$log_file"
unset -v log_dir log_file
