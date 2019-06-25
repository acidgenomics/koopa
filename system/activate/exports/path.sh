#!/bin/sh
# shellcheck disable=SC2236

# Define PATH string.
# Modified 2019-06-20.

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

    id_like="$(cat /etc/os-release | grep ID_LIKE | cut -d "=" -f 2)"

    if echo "$id_like" | grep -q "debian"
    then
        id_like="debian"
    elif echo "$id_like" | grep -q "fedora"
    then
        id_like="fedora"
    else
        id_like=
    fi

    if [ ! -z "${id_like:-}" ]
    then
        _koopa_add_bins_to_path "os/${id_like}"
    fi

    unset -v id_like
fi

_koopa_add_bins_to_path "os/$(koopa os-type)"

# Host type-specific                                                        {{{2
# ------------------------------------------------------------------------------

_koopa_add_bins_to_path "host/$(koopa host-type)"



# Java                                                                      {{{1
# ==============================================================================

if [ -z "${JAVA_HOME:-}" ]
then
    JAVA_HOME="$(_koopa_java_home)"
    if [ ! -z "$JAVA_HOME" ] && [ -d "$JAVA_HOME" ]
    then
        export JAVA_HOME
    else
        unset -v JAVA_HOME
    fi
fi

if [ ! -z "${JAVA_HOME:-}" ]
then
    _koopa_add_to_path_start "${JAVA_HOME}/bin"
fi
