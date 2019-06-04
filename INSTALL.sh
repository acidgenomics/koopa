#!/usr/bin/env bash
set -Eeuxo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

(
    # shellcheck source=/dev/null
    cd "$script_dir"
    git submodule init
    git submodule update
)

# Initialize dotfiles repo and submodules.
(
    # shellcheck source=/dev/null
    cd "${script_dir}/dotfiles"
    git submodule init
    git submodule update
)

# Create dotfiles symlinks.
# shellcheck source=/dev/null
. "${script_dir}/INSTALL/dotfiles.sh"

# Install spacemacs.
# shellcheck source=/dev/null
. "${script_dir}/bin/install-spacemacs"

# Run the updater script.
# shellcheck source=/dev/null
. "${script_dir}/UPDATE.sh"
