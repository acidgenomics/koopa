#!/usr/bin/env bash
set -Eeuxo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

git submodule init
git submodule update

# Initialize dotfiles repo and submodules.
(
    cd dotfiles
    git submodule init
    git submodule update
)

# Create dotfiles symlinks.
. "${script_dir}/INSTALL/dotfiles.sh"

# Install spacemacs.

# Run the updater script.
. "${script_dir}/UPDATE.sh"
