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

# Currently this applies to Fedora/RHEL/CentOS and Amazon Linux 2.
# In the future, add support here for Debian/Ubuntu.
# Putting this in PATH before the OS-specific scripts.
if [ "$os" = "amzn" ]
then
    os_bin_dir="${KOOPA_BIN_DIR}/os/rhel"
    add_to_path_start "$os_bin_dir"
    has_sudo && add_to_path_start "${os_bin_dir}/sudo"
    unset -v os_bin_dir
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
    fi
    unset -v host_bin_dir
fi
unset -v host



# vim: fdm=marker
