#!/bin/sh

# POSIX-compliant functions.
# Modified 2019-06-20.



# Assertive check functions                                                 {{{1
# ==============================================================================

assert_has_no_environments() {
    # Ensure conda is deactivated.
    if [ -x "$(command -v conda)" ] && [ ! -z "${CONDA_PREFIX:-}" ]
    then
        >&2 printf "Error: conda is active.\n"
        exit 1
    fi

    # Ensure Python virtual environment is deactivated.
    if [ -x "$(command -v deactivate)" ]
    then
        >&2 printf "Error: Python virtualenv is active.\n"
        exit 1
    fi
}

assert_has_sudo() {
    if ! has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        exit 1
    fi
}

# Check if directory already exists.
# Modified 2019-06-19.
assert_is_not_dir() {
    local path="$1"
    # Error on existing installation.
    if [ -d "$path" ]
    then
        >&2 printf "Error: Directory already exists.\n%s\n" "$prefix"
        exit 1
    fi
}

assert_is_installed() {
    local program="$1"
    command -v "$program" >/dev/null 2>&1 || {
        >&2 printf "Error: %s is not installed.\n" "$program"
        return 1
    }
}

assert_is_os_darwin() {
    if [ ! "$KOOPA_OS_NAME" = "darwin" ] || [ -z "${MACOS:-}" ]
    then
        >&2 printf "Error: macOS is required.\n"
        exit 1
    fi
}

assert_is_os_debian() {
    if ! grep "ID="      /etc/os-release | grep -q "debian" &&
       ! grep "ID_LIKE=" /etc/os-release | grep -q "debian"
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
}

assert_is_os_fedora() {
    if ! grep "ID="      /etc/os-release | grep -q "fedora" &&
       ! grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
}



# Quiet variants                                                            {{{1
# ==============================================================================

quiet_cd() {
    cd "$@" >/dev/null || return 1
}

# Regular expression matching that is POSIX compliant.
# https://stackoverflow.com/questions/21115121
# Avoid using `[[ =~ ]]` in sh config files.
# `expr` is faster than using `case`.
quiet_expr() {
    expr "$1" : "$2" 1>/dev/null
}

# Consider not using `&>` here, it isn't POSIX.
# https://unix.stackexchange.com/a/80632
# > command -v "$1" >/dev/null
quiet_which() {
    command -v "$1" >/dev/null 2>&1
}



# File system and build utilities                                           {{{1
# ==============================================================================

# Fix the group permissions on the build directory.
# Modified 2019-06-19.
build_chgrp() {
    local path="$1"
    local group="$(build_prefix_group)"
    if has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
}

# Create the build directory.
# Modified 2019-06-19.
build_mkdir() {
    local path="$1"
    assert_is_not_dir "$path"

    if has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi

    build_chgrp "$path"
}

# Return the installation prefix to use.
# Modified 2019-06-19.
build_prefix() {
    if has_sudo
    then
        if echo "$KOOPA_DIR" | grep -Eq "^/opt/"
        then
            prefix="${KOOPA_DIR}/local"
        else
            prefix="/usr/local"
        fi
    else
        prefix="${HOME}/.local"
    fi
    mkdir -p "$prefix"
    echo "$prefix"
}

build_prefix_group() {
    # Standard user.
    ! has_sudo && return "$(whoami)"

    # Administrator.
    if groups | grep -Eq "\b(admin)\b"
    then
        # Darwin (macOS).
        group="admin"
    elif groups | grep -Eq "\b(sudo)\b"
    then
        # Debian.
        group="sudo"
    else
        # Fedora.
        group="wheel"
    fi
    echo "$group"
}

# Modified 2019-06-20.
build_set_permissions() {
    local path="$1"
    
    if has_sudo
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi

    build_chgrp "$path"
}

# Symlink cellar into local build directory.
# e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
link_cellar() {
    assert_has_sudo
    local name="$1"
    local version="$2"
    local prefix="${KOOPA_CELLAR_PREFIX}/${name}/${version}"
    printf "Linking %s in %s.\n" "$prefix" "$KOOPA_BUILD_PREFIX"
    build_set_permissions "$prefix"
    sudo cp -frsv "$prefix/"* "$KOOPA_BUILD_PREFIX"
    build_set_permissions "$KOOPA_BUILD_PREFIX"
}

# Modified 2019-06-19.
delete_dotfile() {
    local path="${HOME}/.${1}"
    local name="$(basename "$path")"
    if [ -L "$path" ]
    then
        printf "Removing '%s'.\n" "$name"
        rm -f "$path"
    elif [ -f "$path" ] || [ -d "$path" ]
    then
        printf "Warning: Not symlink: %s\n" "$name"
    fi
}

# Administrator (sudo) permission.
# Currently performing a simple check by verifying wheel group.
# - Darwin (macOS): admin
# - Debian: sudo
# - Fedora: wheel
# Modified 2019-06-19.
has_sudo() {
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}



# Path string modifiers                                                     {{{1
# ==============================================================================

# Modified from Mike McQuaid's dotfiles.
# https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh

add_to_path_start() {
    [ ! -d "$1" ] && remove_from_path "$1" && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${1}:${PATH}"
}

add_to_path_end() {
    [ ! -d "$1" ] && remove_from_path "$1" && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${PATH}:${1}"
}

force_add_to_path_start() {
    remove_from_path "$1"
    export PATH="${1}:${PATH}"
}

force_add_to_path_end() {
    remove_from_path "$1"
    export PATH="${PATH}:${1}"
}

# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
remove_from_path() {
    # SC2039: In POSIX sh, string replacement is undefined.
    # shellcheck disable=SC2039
    export PATH="${PATH//:$1/}"
}



# Version parsers                                                           {{{1
# ==============================================================================

# Get version stored internally in versions.txt file.
# Modified 2019-06-18.
koopa_variable() {
    local what="$1"
    local file="${KOOPA_DIR}/system/include/variables.txt"
    local match="$(grep -E "^${what}=" "$file" || echo "")"
    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        >&2 printf "Error: %s not defined in %s.\n" "$what" "$file"
        return 1
    fi
}



# System configuration helpers                                              {{{1
# ==============================================================================

# Add local builds to PATH (e.g. '/usr/local').
# This will recurse through the local library and find 'bin/' subdirs.
# Note: read `-a` flag doesn't work on macOS. zsh related?
# Modified 2019-06-20.
add_local_bins_to_path() {
    local prefix="$KOOPA_BUILD_PREFIX"
    add_to_path_start "${prefix}/bin"
    IFS=$'\n'
    read -r -d '' dirs <<< "$(find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        add_to_path_start "$dir"
    done
}

# Add both 'bin/' and 'sbin/' to PATH.
# Modified 2019-06-20.
add_koopa_bins_to_path() {
    local relpath="${1:-}"
    local prefix="$KOOPA_DIR"
    [ ! -z "$relpath" ] && prefix="${prefix}/${relpath}"
    has_sudo && add_to_path_start "${prefix}/sbin"
    add_to_path_start "${prefix}/bin"
}

# Find local bin directories.
#
# See also:
# - https://stackoverflow.com/questions/23356779
# - https://stackoverflow.com/questions/7442417
#
# Modified 2019-06-17.
find_local_bin_dirs() {
    local array=()
    local tmp_file="${KOOPA_TMP_DIR}/find"

    find "$KOOPA_BUILD_PREFIX" \
        -mindepth 2 \
        -maxdepth 3 \
        -name "bin" \
        ! -path "*/Caskroom/*" \
        ! -path "*/Cellar/*" \
        ! -path "*/Homebrew/*" \
        ! -path "*/anaconda3/*" \
        ! -path "*/bcbio/*" \
        ! -path "*/lib/*" \
        ! -path "*/miniconda3/*" \
        -print0 > "$tmp_file"

    while IFS=  read -r -d $'\0'
    do
        array+=("$REPLY")
    done < "$tmp_file"
    rm -f "$tmp_file"

    # Sort the array.
    IFS=$'\n'
    local sorted=($(sort <<<"${array[*]}"))
    unset IFS

    printf "%s\n" "${sorted[@]}"
}

# Update dynamic linker (LD) configuration.
# Modified 2019-06-19.
update_ldconfig() {
    if [ -d /etc/ld.so.conf.d ]
    then
        sudo ln -fs \
            "${KOOPA_DIR}/system/config/etc/ld.so.conf.d/"*".conf" \
            /etc/ld.so.conf.d/.
        sudo ldconfig
    fi
}

# Add shared `koopa.sh` configuration file to `/etc/profile.d/`.
# Modified 2019-06-20.
update_profile() {
    assert_has_sudo
    [ -z "${LINUX:-}" ] && return 0
    local file="/etc/profile.d/koopa.sh"
    printf "Updating '%s'.\n" "$file"
    sudo mkdir -p "$(dirname file)"
    sudo rm -f "$file"
    sudo bash -c "cat << EOF > "$file"
#!/bin/sh

# koopa shell
# https://github.com/acidgenomics/koopa
# shellcheck source=/dev/null
. ${KOOPA_DIR}/activate
EOF"
}

# Add shared R configuration symlinks in `${R_HOME}/etc`.
# Modified 2019-06-19.
update_r_config() {
    assert_has_sudo
    [ -z "${LINUX:-}" ] && return 0

    printf "Updating '/etc/rstudio/'.\n"
    sudo mkdir -p /etc/rstudio
    sudo ln -fs \
        "${KOOPA_DIR}/system/config/etc/rstudio/"* \
        /etc/rstudio/.

    printf "Updating '%s'.\n" "$R_HOME"
    sudo ln -fs \
        "${KOOPA_DIR}/system/config/R/etc/"* \
        "${R_HOME}/etc/".
}

# Update XDG local configuration.
# ~/.config/koopa
# Modified 2019-06-19.
update_xdg_config() {
    mkdir -p "$KOOPA_CONFIG_DIR"
    rm -f "${KOOPA_CONFIG_DIR}/"{activate,home,dotfiles}
    ln -s "${KOOPA_DIR}/activate" "${KOOPA_CONFIG_DIR}/activate"
    ln -s "${KOOPA_DIR}/system/config/dotfiles" "${KOOPA_CONFIG_DIR}/dotfiles"
    ln -s "${KOOPA_DIR}" "${KOOPA_CONFIG_DIR}/home"
}
