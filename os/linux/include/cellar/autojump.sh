#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# This script will error if the system doesn't have 'python' installed.
# I recommend symlinking python3 to python in '/usr/local/bin'.
#
# Run script with '--help' flag for options.
# Note that custom paths are incompatible with '--system' option.
#
# Arch example:
# > ./install.py \
# >     --destdir "${pkgdir}" \
# >     --prefix 'usr/' \
# >     --zshshare 'usr/share/zsh/site-functions'
#
# '--system' defaults:
# - /usr/local
# - _j copied into /usr/share/zsh/site-functions (for zsh)
# - Entry created in /etc/profile.d
#
# See also:
# https://github.com/wting/autojump/issues/338
#
# Install into the temporary and then copy into cellar, after modification.
# Can uninstall with uninstall.py script.
# """

koopa::assert_is_not_installed autojump
koopa::assert_is_not_dir "${HOME}/.autojump"
koopa::assert_is_current_version python
file="release-v${version}.tar.gz"
url="https://github.com/wting/autojump/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "autojump-release-v${version}"
./install.py \
    --destdir "$prefix" \
    --prefix= \
    --zshshare 'share/zsh/site-functions'
