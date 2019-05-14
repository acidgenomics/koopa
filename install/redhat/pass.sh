#!/usr/bin/env bash
set -Eeuxo pipefail

# Pass (password store)
# - https://www.passwordstore.org/
# - https://git.zx2c4.com/password-store

echo "Installing pass."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "${script_dir}/_init.sh"

sudo yum install -y pass
