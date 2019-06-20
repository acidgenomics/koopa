#!/bin/sh
# shellcheck disable=SC2236

# Define PATH string.
# Modified 2019-06-19.

# See also:
# - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

# Note that here we're making sure local binaries are included.
# Inspect `/etc/profile` if system PATH appears misconfigured.



# Standard shared paths                                                     {{{1
# ==============================================================================

add_to_path_end "/usr/local/bin"
add_to_path_end "/usr/bin"
add_to_path_end "/bin"
has_sudo && add_to_path_end "/usr/local/sbin"
has_sudo && add_to_path_end "/usr/sbin"




# Standard local user paths                                                 {{{1
# ==============================================================================

add_to_path_start "${HOME}/bin"
add_to_path_start "${HOME}/local/bin"
add_to_path_start "${HOME}/.local/bin"



# Koopa                                                                     {{{1
# ==============================================================================

add_to_path_start "${KOOPA_DIR}/bin"
has_sudo && add_to_path_start "${KOOPA_DIR}/bin/sudo"

# Shell-specific                                                            {{{2
# ------------------------------------------------------------------------------

[ "$KOOPA_SHELL" = "zsh" ] && \
    add_to_path_start "${KOOPA_DIR}/bin/shell/zsh"

# OS-specific                                                               {{{2
# ------------------------------------------------------------------------------

os="${KOOPA_OS_NAME}"

# - amzn
#   ID_LIKE="centos rhel fedora"
# - rhel
#   ID_LIKE="fedora"
# - ubuntu
#   ID_LIKE=debian

if [ ! -z "${LINUX:-}" ]
then
    add_to_path_start "${KOOPA_DIR}/bin/os/linux"

    id_like="$(cat /etc/os-release | grep ID_LIKE | cut -d "=" -f 2)"

    if echo "$id_like" | grep -q "debian"
    then
        # Debian-like (e.g. Ubuntu)
        os_bin_dir="${KOOPA_DIR}/bin/os/debian"
        add_to_path_start "$os_bin_dir"
        has_sudo && add_to_path_start "${os_bin_dir}/sudo"
        unset -v os_bin_dir
    elif echo "$id_like" | grep -q "fedora"
    then
        # Fedora-like (e.g. RHEL, CentOS, Amazon Linux)
        os_bin_dir="${KOOPA_DIR}/bin/os/fedora"
        add_to_path_start "$os_bin_dir"
        has_sudo && add_to_path_start "${os_bin_dir}/sudo"
        unset -v os_bin_dir
    fi
fi

os_bin_dir="${KOOPA_DIR}/bin/os/${os}"
if [ -d "$os_bin_dir" ]
then
    add_to_path_start "$os_bin_dir"
    has_sudo && add_to_path_start "${os_bin_dir}/sudo"
fi
unset -v os_bin_dir

unset -v os

# Host-specific                                                             {{{2
# ------------------------------------------------------------------------------

host="${KOOPA_HOST_NAME:-}"
if [ ! -z "$host" ]
then
    host_bin_dir="${KOOPA_DIR}/bin/host/${host}"
    if [ -d "$host_bin_dir" ]
    then
        add_to_path_start "$host_bin_dir"
        has_sudo && add_to_path_start "${host_bin_dir}/sudo"
    fi
    unset -v host_bin_dir
fi
unset -v host

# Locally installed programs                                                {{{2
# ------------------------------------------------------------------------------

add_to_path_start "${KOOPA_BUILD_PREFIX}/bin"

IFS=$'\n'
# Note: read `-a` flag doesn't work on macOS. zsh related?
read -r -d '' array <<< "$(find_local_bin_dirs)"
unset IFS
for bin_dir in "${array[@]}"
do
    add_to_path_start "$bin_dir"
done
