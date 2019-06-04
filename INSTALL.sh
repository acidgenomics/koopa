#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
install_dir="${script_dir}/install"


# Initialize submodules                                                     {{{1
# ==============================================================================
(
    # shellcheck source=/dev/null
    cd "$script_dir"
    git submodule init
    git submodule update
)

(
    # shellcheck source=/dev/null
    cd "${script_dir}/dotfiles"
    git submodule init
    git submodule update
)



# Dot file symlinks                                                         {{{1
# ==============================================================================

. "${install_dir}/dotfiles.sh"



# vim: fdm=marker
