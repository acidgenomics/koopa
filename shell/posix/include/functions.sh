#!/bin/sh
# shellcheck disable=SC2039



# A                                                                         {{{1
# ==============================================================================

# Add nested `bin/` and `sbin/` directories to PATH.
# Updated 2019-09-12.
_koopa_add_bins_to_path() {
    local relpath
    local prefix
    relpath="${1:-}"
    prefix="$KOOPA_HOME"
    [ -n "$relpath" ] && prefix="${prefix}/${relpath}"
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
}



# Add conda environment to PATH.
# Experimental: working method to improve pandoc and texlive on RHEL 7.
# Updated 2019-09-12.
_koopa_add_conda_env_to_path() {
    local env_name
    local env_list
    local prefix
    _koopa_is_installed conda || return 1
    env_name="$1"
    env_list="${2:-}"
    prefix="$(_koopa_conda_env_prefix "$env_name" "$env_list")"
    [ -n "$prefix" ] || return 1
    prefix="${prefix}/bin"
    [ -d "$prefix" ] || return 1
    _koopa_add_to_path_start "$prefix"
}



# Add a symlink into the koopa configuration directory.
#
# Examples:
# _koopa_add_config_link vimrc
# _koopa_add_config_link vim
#
# Updated 2019-09-23.
_koopa_add_config_link() {
    local config_dir
    config_dir="$(_koopa_config_dir)"
    local source_file
    source_file="$1"
    _koopa_assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    local dest_name
    dest_name="$2"
    local dest_file
    dest_file="${config_dir}/${dest_name}"
    rm -fv "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
}



# Add directory to end of PATH.
# Updated 2019-09-12.
_koopa_add_to_path_end() {
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${PATH}:${1}"
}



# Add directory to start of PATH.
# Updated 2019-09-12.
_koopa_add_to_path_start() {
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${1}:${PATH}"
}



# Convert a bash array to an R vector string.
# Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
# Updated 2019-09-25.
_koopa_array_to_r_vector() {
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}



# Assert that input contains a file extension.
# Updated 2019-09-26
_koopa_assert_has_file_ext() {
    if ! echo "$1" | grep -q "\."
    then
        >&2 printf "Error: No file extension: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that conda and Python virtual environments aren't active.
# Updated 2019-09-12.
_koopa_assert_has_no_environments() {
    if ! _koopa_has_no_environments
    then
        >&2 printf "Error: Active environment detected.\n"
        exit 1
    fi
    return 0
}



# Assert that current user has sudo (admin) permissions.
# Updated 2019-09-28.
_koopa_assert_has_sudo() {
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required.\n"
        exit 1
    fi
    return 0
}



# Assert that platform is Darwin (macOS).
# Updated 2019-09-23.
_koopa_assert_is_darwin() {
    if ! _koopa_is_darwin
    then
        >&2 printf "Error: macOS (Darwin) is required.\n"
        exit 1
    fi
    return 0
}



# Assert that input is a directory.
# Updated 2019-09-12.
_koopa_assert_is_dir() {
    if [ ! -d "$1" ]
    then
        >&2 printf "Error: Not a directory: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is executable.
# Updated 2019-09-24.
_koopa_assert_is_executable() {
    if [ ! -x "$1" ]
    then
        >&2 printf "Error: Not executable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input exists on disk.
#
# Note that '-e' flag returns true for file, dir, or symlink.
#
# Updated 2019-09-24.
_koopa_assert_is_existing() {
    if [ ! -e "$1" ]
    then
        >&2 printf "Error: Does not exist: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is a file.
# Updated 2019-09-12.
_koopa_assert_is_file() {
    if [ ! -f "$1" ]
    then
        >&2 printf "Error: Not a file: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input matches a specified file type.
#
# Example: _koopa_assert_is_file_type "$x" "csv"
#
# Updated 2019-09-24.
_koopa_assert_is_file_type() {
    _koopa_assert_is_file "$1"
    _koopa_assert_matches_pattern "$1" "\.${2}\$"
}



# Assert that programs are installed.
#
# Supports checking of multiple programs in a single call.
# Note that '_koopa_is_installed' is not vectorized.
#
# Updated 2019-09-24.
_koopa_assert_is_installed() {
    for arg in "$@"
    do
        if ! _koopa_is_installed "$arg"
        then
            >&2 printf "Error: '%s' is not installed.\n" "$arg"
            exit 1
        fi
    done
    return 0
}



# Assert that platform is Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux() {
    if ! _koopa_is_linux
    then
        >&2 printf "Error: Linux is required.\n"
        exit 1
    fi
    return 0
}



# Assert that platform is Debian Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux_debian() {
    if ! _koopa_is_linux_debian
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
    return 0
}



# Assert that platform is Fedora Linux.
# Updated 2019-09-12.
_koopa_assert_is_linux_fedora() {
    if ! _koopa_is_linux_fedora
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
    return 0
}



# Assert that input does not exist on disk.
# Updated 2019-09-23.
_koopa_assert_is_non_existing() {
    if [ -e "$1" ]
    then
        >&2 printf "Error: Exists: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is not a directory.
# Updated 2019-09-29.
_koopa_assert_is_not_dir() {
    if [ -d "$1" ]
    then
        >&2 printf "Error: Directory exists: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is not a file.
# Updated 2019-09-24.
_koopa_assert_is_not_file() {
    if [ -f "$1" ]
    then
        >&2 printf "Error: Is file: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is not a symbolic link.
# Updated 2019-09-24.
_koopa_assert_is_not_symlink() {
    if [ -L "$1" ]
    then
        >&2 printf "Error: Is symlink: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is readable.
# Updated 2019-09-24.
_koopa_assert_is_readable() {
    if [ ! -r "$1" ]
    then
        >&2 printf "Error: Not readable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is a symbolic link.
# Updated 2019-09-24.
_koopa_assert_is_symlink() {
    if [ ! -L "$1" ]
    then
        >&2 printf "Error: Is symlink: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input is writable.
# Updated 2019-09-24.
_koopa_assert_is_writable() {
    if [ ! -r "$1" ]
    then
        >&2 printf "Error: Not writable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}



# Assert that input matches a pattern.
#
# Bash alternative:
# > [[ ! $1 =~ $2 ]]
#
# Updated 2019-09-24.
_koopa_assert_matches_pattern() {
    if ! echo "$1" | grep -q "$2"
    then
        >&2 printf "Error: '%s' does not match pattern '%s'.\n" "$1" "$2"
        exit 1
    fi
    return 0
}



# B                                                                         {{{1
# ==============================================================================

# Extract the file basename without extension.
#
# Examples:
# _koopa_basename_sans_ext "hello-world.txt"
# ## hello-world
#
# _koopa_basename_sans_ext "hello-world.tar.gz"
# ## hello-world.tar
#
# See also: _koopa_file_ext
#
# Updated 2019-09-26.
_koopa_basename_sans_ext() {
    _koopa_assert_has_file_ext "$1"
    printf "%s\n" "${1%.*}"
}



# Extract the file basename prior to any dots in file name.
#
# Examples
# _koopa_basename_sans_ext2 "hello-world.tar.gz"
# ## hello-world
#
# See also: _koopa_file_ext2
#
# Updated 2019-09-26.
_koopa_basename_sans_ext2() {
    _koopa_assert_has_file_ext "$1"
    echo "$1" | cut -d '.' -f 1
}



# Updated 2019-09-27.
_koopa_bash_version() {
    bash --version | \
        head -n 1 | \
        cut -d ' ' -f 4 | \
        cut -d '(' -f 1
}



# Build string for `make` configuration.
#
# Use this for `configure --build` flag.
#
# This function will distinguish between RedHat, Amazon, and other distros
# instead of just returning "linux". Note that we're substituting "redhat"
# instead of "rhel" here, when applicable.
#
# - AWS:    x86_64-amzn-linux-gnu
# - Darwin: x86_64-darwin15.6.0
# - RedHat: x86_64-redhat-linux-gnu
#
# Updated 2019-09-27.
_koopa_build_os_string() {
    local mach
    local os_type
    local string
    mach="$(uname -m)"
    if _koopa_is_darwin
    then
        string="${mach}-${OSTYPE}"
    else
        os_type="$(_koopa_os_type)"
        if echo "$os_type" | grep -q "rhel"
        then
            os_type="redhat"
        fi
        string="${mach}-${os_type}-${OSTYPE}"
    fi
    echo "$string"
}



# Return the installation prefix to use.
# Updated 2019-09-27.
_koopa_build_prefix() {
    local prefix
    if _koopa_is_shared && _koopa_has_sudo
    then
        prefix="/usr/local"
    else
        prefix="${HOME}/.local"
    fi
    echo "$prefix"
}



# Set permissions on program built from source.
# Updated 2019-06-27.
_koopa_build_set_permissions() {
    local path
    path="$1"
    if _koopa_has_sudo
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi
    _koopa_prefix_chgrp "$path"
}



# C                                                                         {{{1
# ==============================================================================

# Avoid setting to `/usr/local/cellar`, as this can conflict with Homebrew.
# Updated 2019-09-27.
_koopa_cellar_prefix() {
    local prefix
    if [ -w "$KOOPA_HOME" ]
    then
        prefix="${KOOPA_HOME}/cellar"
    else
        if [ -z "${XDG_DATA_HOME:-}" ]
        then
            >&2 printf "Warning: 'XDG_DATA_HOME' is unset.\n"
            XDG_DATA_HOME="${HOME}/.local/share"
        fi
        prefix="${XDG_DATA_HOME}/koopa/cellar"
    fi
    echo "$prefix"
}



# Updated 2019-09-23.
_koopa_cellar_script() {
    _koopa_assert_has_no_environments
    local name
    name="$1"
    file="${KOOPA_HOME}/system/include/cellar/${name}.sh"
    if [ ! -f "$file" ]
    then
        >&2 printf "Error: No script found for '%s'.\n" "$name"
        return 1
    fi
    echo "$file"
}



# Updated 2019-06-27.
_koopa_conda_env_list() {
    _koopa_is_installed conda || return 1
    conda env list --json
}



# Note that we're allowing env_list passthrough as second positional variable,
# to speed up loading upon activation.
# Updated 2019-06-27.
_koopa_conda_env_prefix() {
    local env_name
    local env_list
    local prefix
    local path
    _koopa_is_installed conda || return 1
    env_name="$1"
    env_list="${2:-}"
    prefix="$(_koopa_conda_prefix)"
    if [ -z "$env_list" ]
    then
        env_list="$(_koopa_conda_env_list)"
    fi
    # Restrict to environments that match internal koopa installs.
    # Early return if no environments are installed.
    env_list="$(echo "$env_list" | grep "$prefix")"
    [ -z "$env_list" ] && return 1
    path="$( \
        echo "$env_list" | \
        grep "/envs/${env_name}" \
    )"
    [ -z "$path" ] && return 1
    echo "$path" | sed -E 's/^.*"(.+)".*$/\1/'
}



# Updated 2019-09-27.
_koopa_config_dir() {
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        >&2 printf "Warning: 'XDG_CONFIG_HOME' is unset.\n"
        XDG_CONFIG_HOME="${HOME}/.config"
    fi
    echo "${XDG_CONFIG_HOME}/koopa"
}



# Updated 2019-09-27.
_koopa_conda_prefix() {
    local prefix
    if [ -w "$KOOPA_HOME" ]
    then
        prefix="${KOOPA_HOME}/conda"
    else
        if [ -z "${XDG_DATA_HOME:-}" ]
        then
            >&2 printf "Warning: 'XDG_DATA_HOME' is unset.\n"
            XDG_DATA_HOME="${HOME}/.local/share"
        fi
        prefix="${XDG_DATA_HOME}/koopa/conda"
    fi
    echo "$prefix"
}



# D                                                                         {{{1
# ==============================================================================

# Delete a dot file.
# Updated 2019-06-27.
_koopa_delete_dotfile() {
    local path
    local name
    path="${HOME}/.${1}"
    name="$(basename "$path")"
    if [ -L "$path" ]
    then
        printf "Removing '%s'.\n" "$name"
        rm -f "$path"
    elif [ -f "$path" ] || [ -d "$path" ]
    then
        printf "Warning: Not symlink: %s\n" "$name"
    fi
}



# Check that disk has enough free space.
# Updated 2019-08-15.
_koopa_disk_check() {
    local used
    local limit
    used="$(_koopa_disk_pct_used "$@")"
    limit="90"
    if [ "$used" -gt "$limit" ]
    then
        >&2 printf "Warning: Disk usage is %d%%.\n" "$used"
    fi
}



# Check disk usage on main drive.
# Updated 2019-08-17.
_koopa_disk_pct_used() {
    local disk
    disk="${1:-/}"
    df "$disk" | \
        head -n 2  | \
        sed -n '2p' | \
        grep -Eo "([.0-9]+%)" | \
        head -n 1 | \
        sed 's/%$//'
}



# E                                                                         {{{1
# ==============================================================================

# Extract compressed files automatically.
#
# As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
#
# See also:
# - https://github.com/stephenturner/oneliners
#
# Updated 2019-09-09.
_koopa_extract() {
    local file
    file="$1"
    if [ ! -f "$file" ]
    then
        >&2 printf "Error: Invalid file: %s\n" "$file"
        return 1
    fi
    case "$file" in
        *.tar.bz2)
            tar xvjf "$file"
            ;;
        *.tar.gz)
            tar xvzf "$file"
            ;;
        *.tar.xz)
            tar Jxvf "$file"
            ;;
        *.bz2)
            bunzip2 "$file"
            ;;
        *.gz)
            gunzip "$file"
            ;;
        *.rar)
            unrar x "$file"
            ;;
        *.tar)
            tar xvf "$file"
            ;;
        *.tbz2)
            tar xvjf "$file"
            ;;
        *.tgz)
            tar xvzf "$file"
            ;;
        *.zip)
            unzip "$file"
            ;;
        *.Z)
            uncompress "$file"
            ;;
        *.7z)
            7z x "$file"
            ;;
        *)
            >&2 printf "Error: Unsupported extension: %s\n" "$file"
            ;;
   esac
}



# F                                                                         {{{1
# ==============================================================================

# Updated 2019-09-24.
_koopa_find_dotfiles() {
    local type="$1"
    local header="$2"
    printf "\n%s:\n\n" "$header"
    find ~ \
        -maxdepth 1 \
        -name ".*" \
        -type "$type" \
        -print0 | \
        xargs -0 -n1 basename | \
        sort |
        awk '{print "  ",$0}'
}



# Find text in any file.
#
# See also: https://github.com/stephenturner/oneliners
#
# Examples:
# _koopa_find_text "mytext" *.txt
#
# Updated 2019-09-05.
_koopa_find_text() {
    find . -name "$2" -exec grep -il "$1" {} \;;
}



# Extract the file extension from input.
#
# Examples:
# _koopa_file_ext "hello-world.txt"
# ## txt
#
# _koopa_file_ext "hello-world.tar.gz"
# ## gz
#
# See also: _koopa_basename_sans_ext
#
# Updated 2019-09-26.
_koopa_file_ext() {
    _koopa_assert_has_file_ext "$1"
    printf "%s\n" "${1##*.}"
}



# Extract the file extension after any dots in the file name.
# This assumes file names are not in dotted case.
#
# Examples:
# _koopa_file_ext2 "hello-world.tar.gz"
# ## tar.gz
#
# See also: _koopa_basename_sans_ext2
#
# Updated 2019-09-26.
_koopa_file_ext2() {
    _koopa_assert_has_file_ext "$1"
    echo "$1" | cut -d '.' -f 2-
}



# Updated 2019-06-27.
_koopa_force_add_to_path_end() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_end "$dir"
}



# Updated 2019-06-27.
_koopa_force_add_to_path_start() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_start "$dir"
}



# H                                                                         {{{1
# ==============================================================================

# Detect activation of virtual environments.
# Updated 2019-06-25.
_koopa_has_no_environments() {
    [ -x "$(command -v conda)" ] && [ -n "${CONDA_PREFIX:-}" ] && return 1
    [ -x "$(command -v deactivate)" ] && return 1
    return 0
}



# Check that current user has administrator (sudo) permission.
#
# Note that use of 'sudo -v' does not work consistently across platforms.
#
# - Darwin (macOS): admin
# - Debian: sudo
# - Fedora: wheel
#
# Updated 2019-09-28.
_koopa_has_sudo() {
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}



# Source script header.
# Updated 2019-09-27.
_koopa_header() {
    local path
    if [ -z "${1:-}" ]
    then
        >&2 cat << EOF
error: TYPE argument missing.
usage: _koopa_header TYPE

shell:
    - bash
    - zsh

os type:
    - darwin
    - linux
        - debian
            - ubuntu
        - fedora
            - [rhel]
                - amzn

host type:
    - azure
    - harvard-o2
    - harvard-odyssey
EOF

        return 1
    fi
    
    case "$1" in
        # shell ----------------------------------------------------------------
        bash)
            path="${KOOPA_HOME}/shell/bash/include/header.sh"
            ;;
        zsh)
            path="${KOOPA_HOME}/shell/zsh/include/header.sh"
            ;;
        # os -------------------------------------------------------------------
        darwin)
            path="${KOOPA_HOME}/os/darwin/include/header.sh"
            ;;
        linux)
            path="${KOOPA_HOME}/os/linux/include/header.sh"
            ;;
            debian)
                path="${KOOPA_HOME}/os/debian/include/header.sh"
                ;;
                ubuntu)
                    path="${KOOPA_HOME}/os/ubuntu/include/header.sh"
                    ;;
            fedora)
                path="${KOOPA_HOME}/os/fedora/include/header.sh"
                ;;
                amzn)
                    path="${KOOPA_HOME}/os/amzn/include/header.sh"
                    ;;
        # host -----------------------------------------------------------------
        azure)
            path="${KOOPA_HOME}/host/azure/include/header.sh"
            ;;
        harvard-o2)
            path="${KOOPA_HOME}/host/harvard-o2/include/header.sh"
            ;;
        harvard-odyssey)
            path="${KOOPA_HOME}/host/harvard-odyssey/include/header.sh"
            ;;
        *)
            >&2 printf "Error: '%s' is not supported.\n" "$1"
            return 1
            ;;
    esac
    echo "$path"
}



# Show usage via help flag.
# Updated 2019-09-26.
_koopa_help() {
    case "${1:-}" in
        --help|-h)
            usage
            exit 0
            ;;
    esac
}



# Updated 2019-08-18.
_koopa_home() {
    echo "$KOOPA_HOME"
}



# Simple host type name string to load up host-specific scripts.
# Currently intended to support AWS, Azure, and Harvard clusters.
#
# Returns useful host type matching either:
# - VMs: "aws", "azure".
# - HPCs: "harvard-o2", "harvard-odyssey".
#
# Returns empty for local machines and/or unsupported types.
# Updated 2019-08-18.
_koopa_host_type() {
    local name
    case "$(hostname -f)" in
        # VMs
        *.ec2.internal)
            name="aws"
            ;;
        azlabapp*)
            name="azure"
            ;;
        # HPCs
        *.o2.rc.hms.harvard.edu)
            name="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            name="harvard-odyssey"
            ;;
        *)
            name=
            ;;
    esac
    echo "$name"
}



# I                                                                         {{{1
# ==============================================================================

# Using unicode box drawings here.
# Note that we're truncating lines inside the box to 68 characters.
# Updated 2019-09-10.
_koopa_info_box() {
    local array
    array=("$@")
    local barpad
    barpad="$(printf "━%.0s" {1..70})"
    printf "  %s%s%s  \n"  "┏" "$barpad" "┓"
    for i in "${array[@]}"
    do
        printf "  ┃ %-68s ┃  \n"  "${i::68}"
    done
    printf "  %s%s%s  \n\n"  "┗" "$barpad" "┛"
}



# Updated 2019-06-22.
_koopa_is_darwin() {
    [ "$(uname -s)" = "Darwin" ]
}



# Updated 2019-10-02.
_koopa_is_installed() {
    local program
    program="$1"
    command -v "$program" >/dev/null
}



# Updated 2019-06-21.
_koopa_is_interactive() {
    echo "$-" | grep -q "i"
}



# Updated 2019-06-21.
_koopa_is_linux() {
    [ "$(uname -s)" = "Linux" ]
}



# Updated 2019-06-24.
_koopa_is_linux_debian() {
    [ -f /etc/os-release ] || return 1
    grep "ID="      /etc/os-release | grep -q "debian" ||
    grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}



# Updated 2019-06-24.
_koopa_is_linux_fedora() {
    [ -f /etc/os-release ] || return 1
    grep "ID="      /etc/os-release | grep -q "fedora" ||
    grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}



# Updated 2019-06-25.
_koopa_is_local() {
    echo "$KOOPA_HOME" | grep -Eq "^${HOME}"
}



# Updated 2019-08-14.
_koopa_is_login() {
    echo "$0" | grep -Eq "^-"
}



# Updated 2019-06-21.
_koopa_is_login_bash() {
    [ "$0" = "-bash" ]
}



# Updated 2019-06-21.
_koopa_is_login_zsh() {
    [ "$0" = "-zsh" ]
}



# Updated 2019-06-25.
_koopa_is_remote() {
    [ -n "${SSH_CONNECTION:-}" ]
}



# Updated 2019-06-25.
_koopa_is_shared() {
    ! _koopa_is_local
}



# J                                                                         {{{1
# ==============================================================================

# Set JAVA_HOME environment variable.
#
# See also:
# - https://www.mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
# - https://stackoverflow.com/questions/22290554
#
# Updated 2019-10-02.
_koopa_java_home() {
    # Early return if environment variable is set.
    if [ -n "${JAVA_HOME:-}" ]
    then
        echo "$JAVA_HOME"
        return 0
    fi
    # Early return if Java is not installed.
    if ! _koopa_is_installed java
    then
        return 1
    fi

    local home
    local jvm_dir

    # Use automatic detection on macOS.
    if _koopa_is_darwin
    then
        home="$(/usr/libexec/java_home)"
        echo "$home"
        return 0
    fi

    jvm_dir="/usr/lib/jvm"
    if [ ! -d "$jvm_dir" ]
    then
        home=
    elif [ -d "${jvm_dir}/java-12-oracle" ]
    then
        home="${jvm_dir}/java-12-oracle"
    elif [ -d "${jvm_dir}/java-12" ]
    then
        home="${jvm_dir}/java-12"
    elif [ -d "${jvm_dir}/java" ]
    then
        home="${jvm_dir}/java"
    else
        home=
    fi

    [ -d "$home" ] || return 0
    echo "$home"
}



# L                                                                         {{{1
# ==============================================================================

# Symlink cellar into build directory.
# e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
# Updated 2019-09-28.
_koopa_link_cellar() {
    local name
    local version
    local cellar_prefix
    local build_prefix
    name="$1"
    version="$2"
    cellar_prefix="$(_koopa_cellar_prefix)/${name}/${version}"
    build_prefix="$(_koopa_build_prefix)"
    printf "Linking %s in %s.\n" "$cellar_prefix" "$build_prefix"
    _koopa_build_set_permissions "$cellar_prefix"
    cp -frsv "$cellar_prefix/"* "$build_prefix/".
    _koopa_build_set_permissions "$build_prefix"
    _koopa_has_sudo && _koopa_update_ldconfig
}



# Locate the realpath of a program.
#
# This resolves symlinks automatically.
# For 'which' style return, use '_koopa_which' instead.
#
# See also:
# - https://stackoverflow.com/questions/7522712
# - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
#
# Examples:
# _koopa_locate bash
# ## /usr/local/Cellar/bash/5.0.11/bin/bash
#
# Updated 2019-10-02.
_koopa_locate() {
    local command
    command="$1"
    local which
    which="$(_koopa_which "$command")"
    local path
    path="$(realpath "$which")"
    echo "$path"
}



# M                                                                         {{{1
# ==============================================================================

# Extract the version of a macOS application.
# Updated 2019-09-28.
_koopa_macos_app_version() {
    _koopa_assert_is_darwin
    plutil -p "/Applications/${1}.app/Contents/Info.plist" | \
        grep CFBundleShortVersionString |
        awk -F ' => ' '{print $2}' |
        tr -d '"'
}



# Updated 2019-08-17.
_koopa_macos_version() {
    _koopa_assert_is_darwin
    printf "%s %s (%s)\n" \
        "$(sw_vers -productName)" \
        "$(sw_vers -productVersion)" \
        "$(sw_vers -buildVersion)"
}



# Updated 2019-08-17.
_koopa_macos_version_short() {
    _koopa_assert_is_darwin
    version="$(sw_vers -productVersion | cut -d '.' -f 1-2)"
    printf "%s %s\n" "macos" "$version"
}



# Get the major program version.
# Updated 2019-09-23.
_koopa_major_version() {
    echo "$1" | cut -d '.' -f 1-2
}



# Get the minor program version.
# Updated 2019-09-23.
_koopa_minor_version() {
    echo "$1" | cut -d "." -f 2-
}



# O                                                                         {{{1
# ==============================================================================

# Operating system name.
# Always returns lowercase, with unique names for Linux distros (e.g. "debian").
# Updated 2019-08-16.
_koopa_os_type() {
    local id
    if _koopa_is_darwin
    then
        id="$(uname -s | tr '[:upper:]' '[:lower:]')"
    elif _koopa_is_linux
    then
        id="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        # Include the major release version for RHEL.
        if [ "$id" = "rhel" ]
        then
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
                tr -d '"' | \
                cut -d '.' -f 1
            )"
            id="${id}${version}"
        fi
    else
        id=""
    fi
    echo "$id"
}



# Updated 2019-06-22.
# Note that this returns Darwin version information for macOS.
_koopa_os_version() {
    uname -r
}



# P                                                                         {{{1
# ==============================================================================

# Fix the group permissions on the build directory.
# Updated 2019-09-27.
_koopa_prefix_chgrp() {
    local path
    local group
    path="$1"
    group="$(_koopa_prefix_group)"
    if _koopa_has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
}



# Set the admin or regular user group automatically.
# Updated 2019-09-27.
_koopa_prefix_group() {
    local group
    if _koopa_is_shared && _koopa_has_sudo
    then
        if groups | grep -Eq "\b(admin)\b"
        then
            group="admin"
        elif groups | grep -Eq "\b(sudo)\b"
        then
            group="sudo"
        elif groups | grep -Eq "\b(wheel)\b"
        then
            group="wheel"
        else
            group="$(whoami)"
        fi
    else
        group="$(whoami)"
    fi
    echo "$group"
}



# Create directory in build prefix.
# Updated 2019-09-27.
_koopa_prefix_mkdir() {
    local path
    path="$1"
    _koopa_assert_is_not_dir "$path"
    if _koopa_has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi
    _koopa_prefix_chgrp "$path"
}



# Get conda environment name for prompt string.
# Updated 2019-08-17.
_koopa_prompt_conda_env() {
    local name
    if [ -n "${CONDA_DEFAULT_ENV:-}" ]
    then
        name="$CONDA_DEFAULT_ENV"
    else
        name=""
    fi
    [ -n "$name" ] && printf " [conda: %s]" "${name}"
}



# Updated 2019-08-17.
_koopa_prompt_disk_used() {
    local pct used
    used="$(_koopa_disk_pct_used)"
    case "$(_koopa_shell)" in
        zsh)
            pct="%%"
            ;;
        *)
            pct="%"
            ;;
    esac
    printf " [disk: %d%s]" "$used" "$pct"
}



# Updated 2019-08-17.
_koopa_prompt_os() {
    local id
    local string
    local version
    if _koopa_is_darwin
    then
        string="$(_koopa_macos_version_short)"
    elif _koopa_is_linux
    then
        id="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        version="$( \
            awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        string="${id} ${version}"
    else
        string=""
    fi
    if _koopa_is_remote
    then
        host_type="$(_koopa_host_type)"
        if [ -n "$host_type" ]
        then
            string="${host_type} ${string}"
        fi
    fi
    echo "$string"
}



# Get Python virtual environment name for prompt string.
# https://stackoverflow.com/questions/10406926
# Updated 2019-08-17.
_koopa_prompt_python_env() {
    local name
    if [ -n "${VIRTUAL_ENV:-}" ]
    then
        # Strip out the path and just leave the env name.
        name="${VIRTUAL_ENV##*/}"
    else
        name=""
    fi
    [ -n "$name" ] && printf " [venv: %s]" "$name"
}



# Q                                                                         {{{1
# ==============================================================================

_koopa_quiet_cd() {
    cd "$@" >/dev/null || return 1
}



# Regular expression matching that is POSIX compliant.
# https://stackoverflow.com/questions/21115121
# Avoid using `[[ =~ ]]` in sh config files.
# `expr` is faster than using `case`.
_koopa_quiet_expr() {
    expr "$1" : "$2" 1>/dev/null
}



# R                                                                         {{{1
# ==============================================================================

# Get `R_HOME`, rather than exporting as global variable.
# Updated 2019-06-27.
_koopa_r_home() {
    _koopa_assert_is_installed R
    _koopa_assert_is_installed Rscript
    Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))'
}



# Update rJava configuration.
# The default Java path differs depending on the system.
# # > R CMD javareconf -h
# # Environment variables that can be used to influence the detection:
#   JAVA           path to a Java interpreter executable
#                  By default first 'java' command found on the PATH
#                  is taken (unless JAVA_HOME is also specified).
#   JAVA_HOME      home of the Java environment. If not specified,
#                  it will be detected automatically from the Java
#                  interpreter.
#   JAVAC          path to a Java compiler
#   JAVAH          path to a Java header/stub generator
#   JAR            path to a Java archive tool
# # Updated 2019-06-27.
_koopa_r_javareconf() {
    local java_home
    local java_flags
    local r_home
    _koopa_is_installed R || return 1
    _koopa_is_installed java || return 1
    # FIXME This is now breaking...
    java_home="$(_koopa_java_home)"
    [ -n "$java_home" ] && [ -d "$java_home" ] || return 1
    printf "Updating R Java configuration.\n"
    java_flags=(
        "JAVA_HOME=${java_home}" \
        "JAVA=${java_home}/bin/java" \
        "JAVAC=${java_home}/bin/javac" \
        "JAVAH=${java_home}/bin/javah" \
        "JAR=${java_home}/bin/jar" \
    )
    r_home="$(_koopa_r_home)"
    _koopa_build_set_permissions "$r_home"
    R --vanilla CMD javareconf "${java_flags[@]}"
    if _koopa_has_sudo
    then
        sudo R --vanilla CMD javareconf "${java_flags[@]}"
    fi
    # > Rscript -e 'install.packages("rJava")'
}



# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
# # Alternate approach using sed:
# > echo "$PATH" | sed "s|:${dir}||g"
# # Updated 2019-07-10.
_koopa_remove_from_path() {
    local dir
    dir="$1"
    export PATH="${PATH//:$dir/}"
}



# Updated 2019-06-21.
_koopa_rsync_flags() {
    echo "--archive --copy-links --delete-before --human-readable --progress"
}



# S                                                                         {{{1
# ==============================================================================

# Note that this isn't necessarily the default shell (`$SHELL`).
# Updated 2019-06-27.
_koopa_shell() {
    local shell
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell="bash"
    elif [ -n "${KSH_VERSION:-}" ]
    then
        shell="ksh"
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell="zsh"
    else
        >&2 cat << EOF
Error: Failed to detect supported shell.
Supported: bash, ksh, zsh.

  SHELL: ${SHELL}
      0: ${0}
      -: ${-}
EOF
        return 1
    fi
    
    echo "$shell"
}



# Strip pattern from left side (start) of string.
#
# Usage: _koopa_lstrip "string" "pattern"
#
# Example: _koopa_lstrip "The Quick Brown Fox" "The "
#
# Updated 2019-09-22.
_koopa_strip_left() {
    printf '%s\n' "${1##$2}"
}



# Strip pattern from right side (end) of string.
#
# Usage: _koopa_rstrip "string" "pattern"
#
# Example: _koopa_rstrip "The Quick Brown Fox" " Fox"
#
# Updated 2019-09-22.
_koopa_strip_right() {
    printf '%s\n' "${1%%$2}"
}



# Strip trailing slash in file path string.
#
# Alternate approach using sed:
# > sed 's/\/$//' <<< "$1"
#
# Updated 2019-09-24.
_koopa_strip_trailing_slash() {
    _koopa_strip_right "$1" "/"
}



# T                                                                         {{{1
# ==============================================================================

# Create temporary directory.
#
# Note: macOS requires `env LC_CTYPE=C`.
# Otherwise, you'll see this error: `tr: Illegal byte sequence`.
# This doesn't seem to work reliably, so using timestamp instead.
#
# See also:
# - https://gist.github.com/earthgecko/3089509
#
# Updated 2019-09-04.
_koopa_tmp_dir() {
    local unique
    local dir
    unique="$(date "+%Y%m%d-%H%M%S")"
    dir="/tmp/koopa-$(id -u)-${unique}"
    # This doesn't work well with zsh.
    # > mkdir -p "$dir"
    # > chown "$USER" "$dir"
    # > chmod 0775 "$dir"
    echo "$dir"
}



# Create a dated file today bucket.
# Also adds a `~/today` symlink for quick access.
#
# How to check if a symlink target matches a specific path:
# https://stackoverflow.com/questions/19860345
#
# Updated 2019-09-28.
_koopa_today_bucket() {
    bucket_dir="${HOME}/bucket"
    # Early return if there's no bucket directory on the system.
    if [[ ! -d "$bucket_dir" ]]
    then
        return 0
    fi
    today="$(date +%Y-%m-%d)"
    today_dir="${HOME}/today"
    # Early return if we've already updated the symlink.
    if readlink "$today_dir" | grep -q "$today"
    then
        return 0
    fi
    bucket_today="$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d)"
    mkdir -p "${bucket_dir}/${bucket_today}"
    # Note the use of `-n` flag here.
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    ln -fns "${bucket_dir}/${bucket_today}" "$today_dir"
}



# Trim leading and trailing white-space from string.
#
# This is an alternative to sed, awk, perl and other tools. The function below
# works by finding all leading and trailing white-space and removing it from the
# start and end of the string.
#
# Usage: _koopa_trim_ws "   example   string    "
#
# Example: _koopa_trim_ws "    Hello,  World    "
#
# Updated 2019-09-22.
_koopa_trim_ws() {
    trim="${1#${1%%[![:space:]]*}}"
    trim="${trim%${trim##*[![:space:]]}}"
    printf '%s\n' "$trim"
}



# U                                                                         {{{1
# ==============================================================================

# Update dynamic linker (LD) configuration.
# Updated 2019-07-10.
_koopa_update_ldconfig() {
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    [ -d /etc/ld.so.conf.d ] || return 0
    _koopa_assert_is_installed ldconfig
    local os_type
    os_type="$(_koopa_os_type)"
    local conf_source
    conf_source="${KOOPA_HOME}/os/${os_type}/etc/ld.so.conf.d"
    if [ ! -d "$conf_source" ]
    then
        >&2 printf "Error: source files missing: %s\n" "$conf_source"
        return 1
    fi
    # Create symlinks with "koopa-" prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    printf "Updating ldconfig in '/etc/ld.so.conf.d/'.\n"
    local source_file
    local dest_file
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fnsv "$source_file" "$dest_file"
    done
    sudo ldconfig
}



# Add shared `koopa.sh` configuration file to `/etc/profile.d/`.
# Updated 2019-06-29.
_koopa_update_profile() {
    local file
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    file="/etc/profile.d/koopa.sh"
    if [ -f "$file" ]
    then
        printf "Note: '%s' exists.\n" "$file"
        return 0
    fi
    printf "Adding '%s'.\n" "$file"
    sudo mkdir -p "$(dirname file)"
    sudo bash -c "cat << EOF > $file
#!/bin/sh

# koopa shell
# https://github.com/acidgenomics/koopa
# shellcheck source=/dev/null
. ${KOOPA_HOME}/activate
EOF"
}



# Add shared R configuration symlinks in '${R_HOME}/etc'.
# Updated 2019-09-28.
_koopa_update_r_config() {
    _koopa_has_sudo || return 0
    _koopa_is_installed R || return 0
    local r_home
    r_home="$(_koopa_r_home)"
    # > local version
    # > version="$( \
    # >     R --version | \
    # >     head -n 1 | \
    # >     cut -d ' ' -f 3 | \
    # >     grep -Eo "^[0-9]+\.[0-9]+"
    # > )"
    printf "Updating '%s'.\n" "$r_home"
    local os_type
    os_type="$(_koopa_os_type)"
    local r_etc_source
    r_etc_source="${KOOPA_HOME}/os/${os_type}/etc/R"
    if [ ! -d "$r_etc_source" ]
    then
        >&2 printf "Error: source files missing: %s\n" "$r_etc_source"
        return 1
    fi
    sudo ln -fnsv "${r_etc_source}/"* "${r_home}/etc/".
    printf "Creating site library.\n"
    site_library="${r_home}/site-library"
    sudo mkdir -pv "$site_library"
    _koopa_build_set_permissions "$r_home"
    _koopa_r_javareconf
}



# Update shell configuration.
# Updated 2019-09-28.
_koopa_update_shells() {
    local shell
    local shell_file
    _koopa_assert_has_sudo
    shell="$(_koopa_build_prefix)/bin/${1}"
    shell_file="/etc/shells"
    if ! grep -q "$shell" "$shell_file"
    then
        printf "Updating '%s' to include '%s'.\n" "$shell_file" "$shell"
        sudo sh -c "echo ${shell} >> ${shell_file}"
    fi
    printf "Run 'chsh -s %s %s' to change default shell.\n" "$shell" "$USER"
}



# Update XDG configuration.
# ~/.config/koopa
# Updated 2019-08-28.
_koopa_update_xdg_config() {
    local config_dir
    config_dir="$(_koopa_config_dir)"
    local home_dir
    home_dir="$(_koopa_home)"
    local os_type
    os_type="$(_koopa_os_type)"
    mkdir -pv "$config_dir"
    relink() {
        local source_file
        source_file="$1"
        local dest_file
        dest_file="$2"
        if [ ! -e "$dest_file" ]
        then
            if [ ! -e "$source_file" ]
            then
                >&2 printf "Error: Source file missing: %s\n" "$source_file"
                return 1
            fi
            printf "Updating XDG config in %s.\n" "$config_dir"
            rm -fv "$dest_file"
            ln -fnsv "$source_file" "$dest_file"
        fi
    }
    relink "${home_dir}" "${config_dir}/home"
    relink "${home_dir}/activate" "${config_dir}/activate"
    relink "${home_dir}/os/${os_type}/etc/R" "${config_dir}/R"
}



# V                                                                         {{{1
# ==============================================================================

# Get version stored internally in versions.txt file.
# Updated 2019-06-27.
_koopa_variable() {
    local what
    local file
    local match
    what="$1"
    file="${KOOPA_HOME}/system/include/variables.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"
    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        >&2 printf "Error: %s not defined in %s.\n" "$what" "$file"
        return 1
    fi
}



# W                                                                         {{{1
# ==============================================================================

# Locate which program.
#
# Note that this intentionally doesn't resolve symlinks.
# Use 'koopa_locate' for that instead.
#
# Examples:
# _koopa_which bash
# ## /usr/local/bin/bash
#
# Updated 2019-10-02.
_koopa_which() {
    local command
    command="$1"
    local path
    if [ "$KOOPA_SHELL" = "zsh" ]
    then
        path="$(type -p "$command")"
        if ! echo "$path" | grep -q " is "
        then
            >&2 printf "Warning: Failed to locate '%s'.\n" "$command"
            return 1
        fi
        path="$(echo "$path" | sed -e "s/^${command} is //")"
    else
        path="$(command -v "$command")"
    fi
    if [ -z "$path" ]
    then
        >&2 printf "Warning: Failed to locate '%s'.\n" "$command"
        return 1
    fi
    echo "$path"
}



# Z                                                                         {{{1
# ==============================================================================

# Updated 2019-08-18.
_koopa_zsh_version() {
    zsh --version | \
        head -n 1 | \
        cut -d ' ' -f 2
}
