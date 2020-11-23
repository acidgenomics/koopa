#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://docs.haskellstack.org/en/stable/install_and_upgrade/
# """

# Installer will warn if this local directory doesn't exist.
xdg_bin_dir="${HOME:?}/.local/bin"
koopa::mkdir "$xdg_bin_dir"
koopa::add_to_path_start "$xdg_bin_dir"
file='stack.sh'
url='https://get.haskellstack.org/'
koopa::download "$url" "$file"
chmod +x "$file"
./"${file}" -f -d "$prefix"
