#!/bin/sh

# Define PATH string.
# Updated 2019-10-02.

# See also:
# - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

# Note that here we're making sure local binaries are included.
# Inspect `/etc/profile` if system PATH appears misconfigured.



# Standard paths                                                            {{{1
# ==============================================================================

_koopa_add_to_path_end "/usr/local/bin"
_koopa_add_to_path_end "/usr/bin"
_koopa_add_to_path_end "/bin"

_koopa_has_sudo && 
    _koopa_add_to_path_end "/usr/local/sbin"
_koopa_has_sudo && 
    _koopa_add_to_path_end "/usr/sbin"

_koopa_add_to_path_start "${HOME}/bin"
_koopa_add_to_path_start "${HOME}/local/bin"
_koopa_add_to_path_start "${HOME}/.local/bin"



# Koopa paths                                                               {{{1
# ==============================================================================

_koopa_add_bins_to_path

# Shell-specific                                                            {{{2
# ------------------------------------------------------------------------------

_koopa_add_bins_to_path "shell/${KOOPA_SHELL}"

# OS type-specific                                                          {{{2
# ------------------------------------------------------------------------------

# - ID="amzn"
#   ID_LIKE="centos rhel fedora"
# - ID="rhel"
#   ID_LIKE="fedora"
# - ID="ubuntu"
#   ID_LIKE=debian

if _koopa_is_linux
then
    _koopa_add_bins_to_path "os/linux"
    id_like="$(grep "ID_LIKE" /etc/os-release | cut -d "=" -f 2)"
    if echo "$id_like" | grep -q "debian"
    then
        id_like="debian"
    elif echo "$id_like" | grep -q "fedora"
    then
        id_like="fedora"
    else
        id_like=
    fi
    if [ -n "${id_like:-}" ]
    then
        _koopa_add_bins_to_path "os/${id_like}"
    fi
    unset -v id_like
fi

# Note that this will add Debian or Fedora.
_koopa_add_bins_to_path "os/$(_koopa_os_type)"

# Host type-specific                                                        {{{2
# ------------------------------------------------------------------------------

_koopa_add_bins_to_path "host/$(_koopa_host_type)"

# Private scripts                                                           {{{2
# ------------------------------------------------------------------------------

_koopa_add_to_path_start "$(_koopa_config_dir)/docker/bin"
_koopa_add_to_path_start "$(_koopa_config_dir)/scripts-private/bin"


# Applications                                                              {{{1
# ==============================================================================

# Doom Emacs.
_koopa_add_to_path_start "${HOME}/.emacs.d/bin"
