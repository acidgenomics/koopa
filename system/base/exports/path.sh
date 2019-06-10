#!/bin/sh
# shellcheck disable=SC2236

# Improve PATH consistency.
# Note that here we're making sure local binaries are included.
# `sbin` = superuser binaries.
# https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

# Inspect `/etc/profile` if system PATH is misconfigured.



# Standard path                                                             {{{1
# ==============================================================================

add_to_path_end "${HOME}/local/bin"
add_to_path_end "${HOME}/.local/bin"
add_to_path_end "/usr/local/sbin"
add_to_path_end "/usr/local/bin"
add_to_path_end "/usr/sbin"
add_to_path_end "/usr/bin"
add_to_path_end "/sbin"
add_to_path_end "/bin"
add_to_path_start "$KOOPA_BIN_DIR"
has_sudo && add_to_path_start "${KOOPA_BIN_DIR}/sudo"



# Shell-specific                                                            {{{1
# ==============================================================================
[ "$KOOPA_SHELL" = "zsh" ] && add_to_path_start "${KOOPA_BIN_DIR}/shell/zsh"



# OS-specific                                                               {{{1
# ==============================================================================

os="${KOOPA_OS_NAME}"

# - amzn
#   ID_LIKE="centos rhel fedora"
# - rhel
#   ID_LIKE="fedora"
# - ubuntu
#   ID_LIKE=debian

if [ ! -z "${LINUX:-}" ]
then
    id_like="$(cat /etc/os-release | grep ID_LIKE | cut -d "=" -f 2)"

    if echo "$id_like" | grep -q "debian"
    then
        # Debian-like (e.g. Ubuntu)
        os_bin_dir="${KOOPA_BIN_DIR}/os/debian"
        add_to_path_start "$os_bin_dir"
        has_sudo && add_to_path_start "${os_bin_dir}/sudo"
        unset -v os_bin_dir
    elif echo "$id_like" | grep -q "fedora"
    then
        # Fedora-like (e.g. RHEL, CentOS, Amazon Linux)
        os_bin_dir="${KOOPA_BIN_DIR}/os/fedora"
        add_to_path_start "$os_bin_dir"
        has_sudo && add_to_path_start "${os_bin_dir}/sudo"
        unset -v os_bin_dir
    fi
fi

os_bin_dir="${KOOPA_BIN_DIR}/os/${os}"
if [ -d "$os_bin_dir" ]
then
    add_to_path_start "$os_bin_dir"
    has_sudo && add_to_path_start "${os_bin_dir}/sudo"
fi
unset -v os_bin_dir

unset -v os



# Host-specific                                                             {{{1
# ==============================================================================

host="${KOOPA_HOST_NAME:-}"
if [ ! -z "$host" ]
then
    host_bin_dir="${KOOPA_BIN_DIR}/host/${host}"
    if [ -d "$host_bin_dir" ]
    then
        add_to_path_start "$host_bin_dir"
        has_sudo && add_to_path_start "${host_bin_dir}/sudo"
    fi
    unset -v host_bin_dir
fi
unset -v host



# vim: fdm=marker
