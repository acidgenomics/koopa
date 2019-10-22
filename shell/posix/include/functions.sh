#!/bin/sh
# shellcheck disable=SC2039



# A                                                                         {{{1
# ==============================================================================

_koopa_add_bins_to_path() {
    # Add nested 'bin/' and 'sbin/' directories to PATH.
    # Updated 2019-09-12.
    local relpath
    local prefix
    relpath="${1:-}"
    prefix="$KOOPA_HOME"
    [ -n "$relpath" ] && prefix="${prefix}/${relpath}"
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
}

_koopa_add_conda_env_to_path() {
    # Add conda environment to PATH.
    # Consider warning if the environment is missing.
    # Updated 2019-10-21.
    _koopa_is_installed conda || return 0
    [ -n "${CONDA_PREFIX:-}" ] || return 0
    local bin_dir
    bin_dir="${CONDA_PREFIX}/envs/${1}/bin"
    [ -d "$bin_dir" ] || return 0
    _koopa_add_to_path_start "$bin_dir"
}

_koopa_add_config_link() {
    # Add a symlink into the koopa configuration directory.
    #
    # Examples:
    # _koopa_add_config_link vimrc
    # _koopa_add_config_link vim
    #
    # Updated 2019-09-23.
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

_koopa_add_to_manpath_start() {
    # Add directory to start of MANPATH.
    # Updated 2019-10-11.
    [ ! -d "$1" ] && return 0
    echo "$MANPATH" | grep -q "$1" && return 0
    export MANPATH="${1}:${MANPATH}"
}

_koopa_add_to_path_end() {
    # Add directory to end of PATH.
    # Updated 2019-09-12.
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${PATH}:${1}"
}

_koopa_add_to_path_start() {
    # Add directory to start of PATH.
    # Updated 2019-09-12.
    [ ! -d "$1" ] && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${1}:${PATH}"
}

_koopa_array_to_r_vector() {
    # Convert a bash array to an R vector string.
    # Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
    # Updated 2019-09-25.
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}

_koopa_assert_has_file_ext() {
    # Assert that input contains a file extension.
    # Updated 2019-09-26
    if ! _koopa_has_file_ext "$1"
    then
        >&2 printf "Error: No file extension: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_has_no_environments() {
    # Assert that conda and Python virtual environments aren't active.
    # Updated 2019-10-16.
    if ! _koopa_has_no_environments
    then
        >&2 cat << EOF
Error: Active environment detected.
       (conda and/or python venv)

Deactivate using:
    venv:  deactivate
    conda: conda deactivate

Deactivate venv prior to conda, otherwise conda python may be left in path.
EOF
        exit 1
    fi
    return 0
}

_koopa_assert_has_sudo() {
    # Assert that current user has sudo (admin) permissions.
    # Updated 2019-09-28.
    if ! _koopa_has_sudo
    then
        >&2 printf "Error: sudo is required.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_conda_active() {
    # Assert that a Conda environment is active.
    # Updated 2019-10-20.
    if ! _koopa_is_conda_active
    then
        >&2 printf "Error: No active Conda environment detected.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_darwin() {
    # Assert that platform is Darwin (macOS).
    # Updated 2019-09-23.
    if ! _koopa_is_darwin
    then
        >&2 printf "Error: macOS (Darwin) is required.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_dir() {
    # Assert that input is a directory.
    # Updated 2019-09-12.
    if [ ! -d "$1" ]
    then
        >&2 printf "Error: Not a directory: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_executable() {
    # Assert that input is executable.
    # Updated 2019-09-24.
    if [ ! -x "$1" ]
    then
        >&2 printf "Error: Not executable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_existing() {
    # Assert that input exists on disk.
    # Note that '-e' flag returns true for file, dir, or symlink.
    # Updated 2019-09-24.
    if [ ! -e "$1" ]
    then
        >&2 printf "Error: Does not exist: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_file() {
    # Assert that input is a file.
    # Updated 2019-09-12.
    if [ ! -f "$1" ]
    then
        >&2 printf "Error: Not a file: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_file_type() {
    # Assert that input matches a specified file type.
    #
    # Example: _koopa_assert_is_file_type "$x" "csv"
    #
    # Updated 2019-10-13.
    _koopa_assert_is_file "$1"
    _koopa_assert_is_matching_regex "$1" "\.${2}\$"
}

_koopa_assert_is_git() {
    # Assert that current directory is a git repo.
    # Updated 2019-10-14.
    if ! _koopa_is_git
    then
        >&2 printf "Error: Not a git repo.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_installed() {
    # Assert that programs are installed.
    #
    # Supports checking of multiple programs in a single call.
    # Note that '_koopa_is_installed' is not vectorized.
    #
    # Updated 2019-09-24.
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

_koopa_assert_is_linux() {
    # Assert that platform is Linux.
    # Updated 2019-09-12.
    if ! _koopa_is_linux
    then
        >&2 printf "Error: Linux is required.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_linux_debian() {
    # Assert that platform is Debian Linux.
    # Updated 2019-09-12.
    if ! _koopa_is_linux_debian
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_linux_fedora() {
    # Assert that platform is Fedora Linux.
    # Updated 2019-09-12.
    if ! _koopa_is_linux_fedora
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_non_existing() {
    # Assert that input does not exist on disk.
    # Updated 2019-09-23.
    if [ -e "$1" ]
    then
        >&2 printf "Error: Exists: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_not_dir() {
    # Assert that input is not a directory.
    # Updated 2019-09-29.
    if [ -d "$1" ]
    then
        >&2 printf "Error: Directory exists: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_not_file() {
    # Assert that input is not a file.
    # Updated 2019-09-24.
    if [ -f "$1" ]
    then
        >&2 printf "Error: File exists: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_not_installed() {
    # Assert that programs are not installed.
    # Updated 2019-10-08.
    for arg in "$@"
    do
        if _koopa_is_installed "$arg"
        then
            >&2 printf "Error: '%s' is installed.\n" "$arg"
            exit 1
        fi
    done
    return 0
}

_koopa_assert_is_not_symlink() {
    # Assert that input is not a symbolic link.
    # Updated 2019-09-24.
    if [ -L "$1" ]
    then
        >&2 printf "Error: Symlink exists: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_r_package_installed() {
    # Assert that a specific R package is installed.
    # Updated 2019-10-20.
    if ! _koopa_is_r_package_installed "$1"
    then
        >&2 printf "Error: '%s' R package is not installed.\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_readable() {
    # Assert that input is readable.
    # Updated 2019-09-24.
    if [ ! -r "$1" ]
    then
        >&2 printf "Error: Not readable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_symlink() {
    # Assert that input is a symbolic link.
    # Updated 2019-10-05.
    if [ ! -L "$1" ]
    then
        >&2 printf "Error: Not symlink: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_venv_active() {
    # Assert that a Python virtual environment is active.
    # Updated 2019-10-20.
    _koopa_assert_is_installed pip
    if ! _koopa_is_venv_active
    then
        >&2 printf "Error: No active Python venv detected.\n"
        exit 1
    fi
    return 0
}

_koopa_assert_is_writable() {
    # Assert that input is writable.
    # Updated 2019-09-24.
    if [ ! -r "$1" ]
    then
        >&2 printf "Error: Not writable: '%s'\n" "$1"
        exit 1
    fi
    return 0
}

_koopa_assert_is_matching_fixed() {
    # Assert that input matches a fixed pattern.
    # Updated 2019-10-13.
    if ! _koopa_is_matching_fixed "$1" "$2"
    then
        >&2 printf "Error: '%s' doesn't match fixed pattern '%s'.\n" "$1" "$2"
        exit 1
    fi
    return 0
}

_koopa_assert_is_matching_regex() {
    # Assert that input matches a regular expression pattern.
    # Updated 2019-10-13.
    if ! _koopa_is_matching_regex "$1" "$2"
    then
        >&2 printf "Error: '%s' doesn't match regex pattern '%s'.\n" "$1" "$2"
        exit 1
    fi
    return 0
}



# B                                                                         {{{1
# ==============================================================================

_koopa_basename_sans_ext() {
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
    # Updated 2019-10-08.
    local x
    x="$1"
    if ! _koopa_has_file_ext "$x"
    then
        echo "$x"
        return 0
    fi
    x="$(basename "$x")"
    x="${x%.*}"
    echo "$x"
}

_koopa_basename_sans_ext2() {
    # Extract the file basename prior to any dots in file name.
    #
    # Examples
    # _koopa_basename_sans_ext2 "hello-world.tar.gz"
    # ## hello-world
    #
    # See also: _koopa_file_ext2
    #
    # Updated 2019-10-08.
    local x
    x="$1"
    if ! _koopa_has_file_ext "$x"
    then
        echo "$x"
        return 0
    fi
    basename "$x" | cut -d '.' -f 1
}

_koopa_bash_version() {
    # Updated 2019-09-27.
    bash --version                                                             \
        | head -n 1                                                            \
        | cut -d ' ' -f 4                                                      \
        | cut -d '(' -f 1
}

_koopa_build_os_string() {
    # Build string for 'make' configuration.
    #
    # Use this for 'configure --build' flag.
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

_koopa_build_prefix() {
    # Return the installation prefix to use.
    # Updated 2019-09-27.
    local prefix
    if _koopa_is_shared && _koopa_has_sudo
    then
        prefix="/usr/local"
    else
        prefix="${HOME}/.local"
    fi
    echo "$prefix"
}



# C                                                                         {{{1
# ==============================================================================

_koopa_cellar_prefix() {
    # Cellar prefix.
    # Avoid setting to '/usr/local/cellar', as this can conflict with Homebrew.
    # Updated 2019-10-22.
    echo "${KOOPA_HOME}/cellar"
}

_koopa_cellar_script() {
    # Return source path for a koopa cellar build script.
    # Updated 2019-10-08.
    _koopa_assert_has_no_environments
    local name
    name="$1"
    file="${KOOPA_HOME}/system/include/cellar/${name}.sh"
    _koopa_assert_is_file "$file"
    echo "$file"
}

_koopa_conda_env() {
    # Conda environment name.
    #
    # Alternate approach:
    # > CONDA_PROMPT_MODIFIER="($(basename "$CONDA_PREFIX"))"
    # > export CONDA_PROMPT_MODIFIER
    # > conda="$CONDA_PROMPT_MODIFIER"
    #
    # See also:
    # - https://stackoverflow.com/questions/42481726
    #
    # Updated 2019-10-13.
    echo "${CONDA_DEFAULT_ENV:-}"
}

_koopa_conda_env_list() {
    # Return a list of conda environments in JSON format.
    # Updated 2019-06-27.
    _koopa_is_installed conda || return 1
    conda env list --json
}

_koopa_conda_env_prefix() {
    # Return prefix for a specified conda environment.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: _koopa_conda_env_prefix "deeptools"
    #
    # Updated 2019-10-22.
    _koopa_is_installed conda || return 1

    local env_name
    env_name="$1"
    [ -n "$env_name" ] || return 1

    local env_list
    env_list="${2:-}"
    if [ -z "$env_list" ]
    then
        env_list="$(_koopa_conda_env_list)"
    fi
    env_list="$(echo "$env_list" | grep "$env_name")"
    if [ -z "$env_list" ]
    then
        >&2 printf "Error: Failed to detect prefix for '%s'.\n" "$env_name"
        return 1
    fi

    local path
    path="$(                                                                   \
        echo "$env_list"                                                       \
        | grep "/envs/${env_name}"                                             \
        | head -n 1                                                            \
    )"
    echo "$path" | sed -E 's/^.*"(.+)".*$/\1/'
}

_koopa_conda_internal_prefix() {
    # Path to koopa's internal conda environments.
    # This may be removed in a future update.
    # Updated 2019-10-18.
    echo "${KOOPA_HOME}/conda"
}

_koopa_config_dir() {
    # Updated 2019-09-27.
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        >&2 printf "Warning: 'XDG_CONFIG_HOME' is unset.\n"
        XDG_CONFIG_HOME="${HOME}/.config"
    fi
    echo "${XDG_CONFIG_HOME}/koopa"
}



# D                                                                         {{{1
# ==============================================================================

_koopa_delete_dotfile() {
    # Delete a dot file.
    # Updated 2019-06-27.
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

_koopa_disk_check() {
    # Check that disk has enough free space.
    # Updated 2019-10-14.
    local used
    local limit
    used="$(_koopa_disk_pct_used "$@")"
    limit="90"
    if [ "$used" -gt "$limit" ]
    then
        >&2 printf "Warning: Disk usage is %d%%.\n" "$used"
    fi
}

_koopa_disk_pct_used() {
    # Check disk usage on main drive.
    # Updated 2019-08-17.
    local disk
    disk="${1:-/}"
    df "$disk"                                                                 \
        | head -n 2                                                            \
        | sed -n '2p'                                                          \
        | grep -Eo "([.0-9]+%)"                                                \
        | head -n 1                                                            \
        | sed 's/%$//'
}



# E                                                                         {{{1
# ==============================================================================

_koopa_ensure_newline_at_end_of_file() {
    # Ensure output CSV contains trailing line break.
    #
    # Otherwise 'readr::read_csv()' will skip the last line in R.
    # https://unix.stackexchange.com/questions/31947
    #
    # Benchmarks:
    # vi -ecwq file                                    2.544 sec
    # paste file 1<> file                             31.943 sec
    # ed -s file <<< w                             1m  4.422 sec
    # sed -i -e '$a\' file                         3m 20.931 sec
    #
    # Updated 2019-10-11.
    [ -n "$(tail -c1 "$1")" ] && printf '\n' >>"$1"
}

_koopa_extract() {
    # Extract compressed files automatically.
    #
    # As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    #
    # Updated 2019-09-09.
    local file
    file="$1"
    if [ ! -f "$file" ]
    then
        >&2 printf "Error: Invalid file: %s\n" "$file"
        return 1
    fi
    case "$file" in
        *.tar.bz2)
            tar -xvjf "$file"
            ;;
        *.tar.gz)
            tar -xvzf "$file"
            ;;
        *.tar.xz)
            tar -Jxvf "$file"
            ;;
        *.bz2)
            bunzip2 "$file"
            ;;
        *.gz)
            gunzip "$file"
            ;;
        *.rar)
            unrar -x "$file"
            ;;
        *.tar)
            tar -xvf "$file"
            ;;
        *.tbz2)
            tar -xvjf "$file"
            ;;
        *.tgz)
            tar -xvzf "$file"
            ;;
        *.zip)
            unzip "$file"
            ;;
        *.Z)
            uncompress "$file"
            ;;
        *.7z)
            7z -x "$file"
            ;;
        *)
            >&2 printf "Error: Unsupported extension: %s\n" "$file"
            ;;
   esac
}



# F                                                                         {{{1
# ==============================================================================

_koopa_file_ext() {
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
    # Updated 2019-10-08.
    _koopa_has_file_ext "$1" || return 0
    printf "%s\n" "${1##*.}"
}

_koopa_file_ext2() {
    # Extract the file extension after any dots in the file name.
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # _koopa_file_ext2 "hello-world.tar.gz"
    # ## tar.gz
    #
    # See also: _koopa_basename_sans_ext2
    #
    # Updated 2019-10-08.
    _koopa_has_file_ext "$1" || return 0
    echo "$1" | cut -d '.' -f 2-
}

_koopa_find_dotfiles() {
    # Find dotfiles by type.
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. "Files")
    # Updated 2019-10-22.
    local type="$1"
    local header="$2"
    printf "\n%s:\n\n" "$header"
    find "$HOME"                                                               \
        -maxdepth 1                                                            \
        -name ".*"                                                             \
        -type "$type"                                                          \
        -print0                                                                \
        | xargs -0 -n1 basename                                                \
        | sort                                                                 \
        | awk '{print "  ",$0}'
}

_koopa_find_text() {
    # Find text in any file.
    #
    # See also: https://github.com/stephenturner/oneliners
    #
    # Examples:
    # _koopa_find_text "mytext" *.txt
    #
    # Updated 2019-09-05.
    find . -name "$2" -exec grep -il "$1" {} \;;
}

_koopa_force_add_to_manpath_start() {
    # Updated 2019-10-14.
    _koopa_remove_from_manpath "$1"
    _koopa_add_to_manpath_start "$1"
}

_koopa_force_add_to_path_end() {
    # Updated 2019-10-14.
    _koopa_remove_from_path "$1"
    _koopa_add_to_path_end "$1"
}

_koopa_force_add_to_path_start() {
    # Updated 2019-10-14.
    _koopa_remove_from_path "$1"
    _koopa_add_to_path_start "$1"
}



# G                                                                         {{{1
# ==============================================================================

_koopa_git_branch() {
    # Current git branch name.
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # See also:
    # - _koopa_assert_is_git
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    #
    # Updated 2019-10-13.
    git symbolic-ref --short -q HEAD
}

_koopa_group() {
    # Return the approach group to use with koopa installation.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    #
    # Updated 2019-10-22.
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

_koopa_gsub() {
    # Updated 2019-10-09.
    echo "$1" | sed -E "s/${2}/${3}/g"
}



# H                                                                         {{{1
# ==============================================================================

_koopa_has_file_ext() {
    # Does the input contain a file extension?
    # Simply looks for a "." and returns true/false.
    # Updated 2019-10-08.
    echo "$1" | grep -q "\."
}

_koopa_has_no_environments() {
    # Detect activation of virtual environments.
    # Updated 2019-10-20.
    _koopa_is_conda_active && return 1
    _koopa_is_venv_active && return 1
    return 0
}

_koopa_has_sudo() {
    # Check that current user has administrator (sudo) permission.
    #
    # Note that use of 'sudo -v' does not work consistently across platforms.
    #
    # - Darwin (macOS): admin
    # - Debian: sudo
    # - Fedora: wheel
    #
    # Updated 2019-09-28.
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}

_koopa_header() {
    # Source script header.
    # Useful for private scripts using koopa code outside of package.
    # Updated 2019-09-27.
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

_koopa_help() {
    # Show usage via help flag.
    # Updated 2019-09-26.
    case "${1:-}" in
        --help|-h)
            usage
            exit 0
            ;;
    esac
}

_koopa_help_args() {
    # Standardize the help arguments shown in usage.
    # Updated 2019-10-22.
    cat << EOF
help arguments:
    --help, -h
        Show this help message and exit.
EOF
}

_koopa_home() {
    # Updated 2019-08-18.
    echo "$KOOPA_HOME"
}

_koopa_host_type() {
    # Simple host type name string to load up host-specific scripts.
    # Currently intended to support AWS, Azure, and Harvard clusters.
    #
    # Returns useful host type matching either:
    # - VMs: "aws", "azure".
    # - HPCs: "harvard-o2", "harvard-odyssey".
    #
    # Returns empty for local machines and/or unsupported types.
    # Updated 2019-08-18.
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

_koopa_info_box() {
    # Info box.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    #
    # Updated 2019-10-14.
    local array
    array=("$@")
    local barpad
    barpad="$(printf "━%.0s" {1..70})"
    printf "  %s%s%s  \n" "┏" "$barpad" "┓"
    for i in "${array[@]}"
    do
        printf "  ┃ %-68s ┃  \n" "${i::68}"
    done
    printf "  %s%s%s  \n\n" "┗" "$barpad" "┛"
}

_koopa_is_conda_active() {
    # Is there a Conda environment active?
    # Updated 2019-10-20.
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

_koopa_is_darwin() {
    # Is the operating system Darwin (macOS)?
    # Updated 2019-06-22.
    [ "$(uname -s)" = "Darwin" ]
}

_koopa_is_file_system_case_sensitive() {
    # Is the file system case sensitive?
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # Updated 2019-10-21.
    touch ".acid-checkcase" ".acid-checkCase"
    count="$(find . -maxdepth 1 -iname ".acid-checkcase" | wc -l)"
    _koopa_quiet_rm .acid-check* 
    if [ "$count" -eq 2 ]
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_git() {
    # Is the current working directory a git repository?
    #
    # See also:
    # - https://stackoverflow.com/questions/2180270
    #
    # Updated 2019-10-14.
    if git rev-parse --git-dir > /dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_git_clean() {
    # Is the current git repo clean, or does it have unstaged changes?
    #
    # See also:
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    #
    # Updated 2019-10-14.

    # Are there unstaged changes?
    if ! git diff-index --quiet HEAD --
    then
        return 1
    fi
    
    # In need of a pull or push?
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]
    then
        return 1
    fi
    
    return 0
}

_koopa_is_installed() {
    # Is the requested program name installed?
    # Updated 2019-10-02.
    command -v "$1" >/dev/null
}

_koopa_is_interactive() {
    # Is the current shell interactive?
    # Updated 2019-06-21.
    echo "$-" | grep -q "i"
}

_koopa_is_linux() {
    # Updated 2019-06-21.
    [ "$(uname -s)" = "Linux" ]
}

_koopa_is_linux_debian() {
    # Updated 2019-06-24.
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "debian" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}

_koopa_is_linux_fedora() {
    # Updated 2019-06-24.
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "fedora" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}

_koopa_is_local() {
    # Is koopa installed only for the current user?
    # Updated 2019-06-25.
    echo "$KOOPA_HOME" | grep -Eq "^${HOME}"
}

_koopa_is_login() {
    # Is the current shell a login shell?
    # Updated 2019-08-14.
    echo "$0" | grep -Eq "^-"
}

_koopa_is_login_bash() {
    # Is the current shell a login bash shell?
    # Updated 2019-06-21.
    [ "$0" = "-bash" ]
}

_koopa_is_login_zsh() {
    # Is the current shell a login zsh shell?
    # Updated 2019-06-21.
    [ "$0" = "-zsh" ]
}

_koopa_is_matching_fixed() {
    # Updated 2019-10-14.
    echo "$1" | grep -Fq "$2"
}

_koopa_is_matching_regex() {
    # Updated 2019-10-13.
    echo "$1" | grep -Eq "$2"
}

_koopa_is_r_package_installed() {
    # Is the requested R package installed?
    # Updated 2019-10-20.
    _koopa_is_installed R || return 1
    Rscript -e "\"$1\" %in% rownames(utils::installed.packages())"             \
        | grep -q "TRUE"
}

_koopa_is_remote() {
    # Is the current shell session a remote connection over SSH?
    # Updated 2019-06-25.
    [ -n "${SSH_CONNECTION:-}" ]
}

_koopa_is_shared() {
    # Is koopa installed for all users (shared)?
    # Updated 2019-06-25.
    ! _koopa_is_local
}

_koopa_is_venv_active() {
    # Is there a Python virtual environment active?
    # Updated 2019-10-20.
    [ -n "${VIRTUAL_ENV:-}" ]
}



# J                                                                         {{{1
# ==============================================================================

_koopa_java_home() {
    # Set JAVA_HOME environment variable.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    #
    # Updated 2019-10-08.
    if ! _koopa_is_installed java
    then
        return 0
    fi
    # Early return if environment variable is set.
    if [ -n "${JAVA_HOME:-}" ]
    then
        echo "$JAVA_HOME"
        return 0
    fi
    local home
    if _koopa_is_darwin
    then
        home="$(/usr/libexec/java_home)"
    else
        local java_exe
        java_exe="$(_koopa_realpath "java")"
        home="$(dirname "$(dirname "${java_exe}")")"
    fi
    echo "$home"
}



# L                                                                         {{{1
# ==============================================================================

_koopa_line_count() {
    # Return the number of lines in a file.
    #
    # Example: _koopa_line_count tx2gene.csv
    #
    # Updated 2019-10-05.
    wc -l "$1"                                                                 \
    | xargs                                                                    \
    | cut -d ' ' -f 1
}

_koopa_link_cellar() {
    # Symlink cellar into build directory.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with '_koopa_set_permissions'.
    #
    # Example: _koopa_link_cellar emacs 26.3
    # # '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
    #
    # Updated 2019-10-22.
    local name
    local version
    local build_prefix
    local cellar_prefix
    name="$1"
    version="$2"
    build_prefix="$(_koopa_build_prefix)"
    cellar_prefix="$(_koopa_cellar_prefix)/${name}/${version}"
    printf "Linking %s in %s.\n" "$cellar_prefix" "$build_prefix"
    _koopa_set_permissions "$cellar_prefix"
    if _koopa_is_shared
    then
        _koopa_assert_has_sudo
        sudo cp -frsv "$cellar_prefix/"* "$build_prefix/".
        _koopa_update_ldconfig
    else
        cp -frsv "$cellar_prefix/"* "$build_prefix/".
    fi
}



# M                                                                         {{{1
# ==============================================================================

_koopa_macos_app_version() {
    # Extract the version of a macOS application.
    # Updated 2019-09-28.
    _koopa_assert_is_darwin
    plutil -p "/Applications/${1}.app/Contents/Info.plist"                     \
        | grep CFBundleShortVersionString                                      \
        | awk -F ' => ' '{print $2}'                                           \
        | tr -d '"'
}

_koopa_macos_version() {
    # macOS version string.
    # Updated 2019-08-17.
    _koopa_assert_is_darwin
    printf "%s %s (%s)\n"                                                      \
        "$(sw_vers -productName)"                                              \
        "$(sw_vers -productVersion)"                                           \
        "$(sw_vers -buildVersion)"
}

_koopa_macos_version_short() {
    # Shorter macOS version string.
    # Updated 2019-08-17.
    _koopa_assert_is_darwin
    version="$(sw_vers -productVersion | cut -d '.' -f 1-2)"
    printf "%s %s\n" "macos" "$version"
}

_koopa_major_version() {
    # Get the major program version.
    # Updated 2019-09-23.
    echo "$1" | cut -d '.' -f 1-2
}

_koopa_minor_version() {
    # Get the minor program version.
    # Updated 2019-09-23.
    echo "$1" | cut -d "." -f 2-
}



# O                                                                         {{{1
# ==============================================================================

_koopa_os_type() {
    # Operating system name.
    # Always returns lowercase, with unique names for Linux distros
    # (e.g. "debian").
    # Updated 2019-10-22.
    local id
    if _koopa_is_darwin
    then
        id="$(uname -s | tr '[:upper:]' '[:lower:]')"
    elif _koopa_is_linux
    then
        id="$(                                                                 \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release                   \
            | tr -d '"'                                                        \
        )"
        # Include the major release version for RHEL.
        if [ "$id" = "rhel" ]
        then
            version="$(                                                        \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release       \
                | tr -d '"'                                                    \
                | cut -d '.' -f 1                                              \
            )"
            id="${id}${version}"
        fi
    else
        id=
    fi
    echo "$id"
}

_koopa_os_version() {
    # Operating system version.
    # Updated 2019-06-22.
    # Note that this returns Darwin version information for macOS.
    uname -r
}



# P                                                                         {{{1
# ==============================================================================

_koopa_prefix_chgrp() {
    # Fix the group permissions on the target build prefix.
    # Updated 2019-10-22.
    local path
    local group
    path="$1"
    group="$(_koopa_group)"
    if _koopa_has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
}

_koopa_prefix_mkdir() {
    # Create directory in target build prefix.
    # Sets correct group and write permissions automatically.
    # Updated 2019-10-22.
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

_koopa_prompt() {
    # Prompt string.
    #
    # Note that Unicode characters don't work well with some Windows fonts.
    #
    # User name and host.
    # - bash : user="\u@\h"
    # - zsh  : user="%n@%m"
    #
    # zsh: conda environment activation is messing up '%m'/'%M' flag on macOS.
    # This seems to be specific to macOS and doesn't happen on Linux.
    #
    # See also:
    # - https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/
    #       robbyrussell.zsh-theme
    #
    # Updated 2019-10-14.
    local conda git newline prompt user venv wd
    user="${USER}@${HOSTNAME//.*/}"
    # Note that subshell exec need to be escaped here, so they are evaluated
    # dynamically when the prompt is refreshed.
    conda="\$(_koopa_prompt_conda)"
    git="\$(_koopa_prompt_git)"
    venv="\$(_koopa_prompt_venv)"
    case "$KOOPA_SHELL" in
        bash)
            newline='\n'
            prompt='\$'
            wd='\w'
            ;;
        zsh)
            newline=$'\n'
            prompt='%%'
            wd='%~'
            ;;
    esac
    # Enable colorful prompt, when possible.
    if _koopa_is_matching_fixed "${TERM:-}" "256color"
    then
        local conda_color git_color prompt_color user_color venv_color wd_color
        case "$KOOPA_SHELL" in
            bash)
                conda_color="33"
                git_color="32"
                prompt_color="35"
                user_color="36"
                venv_color="33"
                wd_color="34"
                # Colorize the variable strings.
                conda="\[\033[${conda_color}m\]${conda}\[\033[00m\]"
                git="\[\033[${git_color}m\]${git}\[\033[00m\]"
                prompt="\[\033[${prompt_color}m\]${prompt}\[\033[00m\]"
                user="\[\033[${user_color}m\]${user}\[\033[00m\]"
                venv="\[\033[${venv_color}m\]${venv}\[\033[00m\]"
                wd="\[\033[${wd_color}m\]${wd}\[\033[00m\]"
                ;;
            zsh)
                # SC2154: fg is referenced but not assigned.
                # shellcheck disable=SC2154
                conda_color="${fg[yellow]}"
                git_color="${fg[green]}"
                prompt_color="${fg[magenta]}"
                user_color="${fg[cyan]}"
                venv_color="${fg[yellow]}"
                wd_color="${fg[blue]}"
                # Colorize the variable strings.
                conda="%F%{${conda_color}%}${conda}%f"
                git="%F%{${git_color}%}${git}%f"
                prompt="%F%{${prompt_color}%}${prompt}%f"
                user="%F%{${user_color}%}${user}%f"
                venv="%F%{${venv_color}%}${venv}%f"
                wd="%F%{${wd_color}%}${wd}%f"
                ;;
        esac
    fi
    printf "%s%s%s%s%s%s%s%s%s " \
        "$newline" \
        "$user" "$conda" "$venv" \
        "$newline" \
        "$wd" "$git" \
        "$newline" \
        "$prompt"
}

_koopa_prompt_conda() {
    # Get conda environment name for prompt string.
    # Updated 2019-10-13.
    local env
    env="$(_koopa_conda_env)"
    if [ -n "$env" ]
    then
        printf " conda:%s\n" "${env}"
    else
        return 0
    fi
}

_koopa_prompt_disk_used() {
    # Get current disk usage on primary drive.
    # Updated 2019-10-13.
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
    printf " disk:%d%s\n" "$used" "$pct"
}

_koopa_prompt_git() {
    # Return the current git branch, if applicable.
    # Also indicate status with "*" if dirty (i.e. has unstaged changes).
    # Updated 2019-10-14.
    _koopa_is_git || return 0
    local git_branch git_status
    git_branch="$(_koopa_git_branch)"
    if _koopa_is_git_clean
    then
        git_status=""
    else
        git_status="*"
    fi
    printf " %s%s\n" "$git_branch" "$git_status"
}

_koopa_prompt_os() {
    # Get the operating system information.
    # Updated 2019-10-22.
    local id
    local string
    local version
    if _koopa_is_darwin
    then
        string="$(_koopa_macos_version_short)"
    elif _koopa_is_linux
    then
        id="$(                                                                 \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release                   \
            | tr -d '"'                                                        \
        )"
        version="$(                                                            \
            awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release           \
            | tr -d '"'                                                        \
        )"
        string="${id}-${version}"
    else
        string=
    fi
    if _koopa_is_remote
    then
        host_type="$(_koopa_host_type)"
        if [ -n "$host_type" ]
        then
            string="${host_type}-${string}"
        fi
    fi
    echo "$string"
}

_koopa_prompt_venv() {
    # Get Python virtual environment name for prompt string.
    # https://stackoverflow.com/questions/10406926
    # Updated 2019-10-13.
    local env
    env="$(_koopa_venv)"
    if [ -n "$env" ]
    then
        printf " venv:%s\n" "${env}"
    else
        return 0
    fi
}



# Q                                                                         {{{1
# ==============================================================================

_koopa_quiet_cd() {
    # Updated 2019-10-08.
    cd "$@" >/dev/null || return 1
}

_koopa_quiet_expr() {
    # Regular expression matching that is POSIX compliant.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    #
    # Updated 2019-10-08.
    expr "$1" : "$2" 1>/dev/null
}

_koopa_quiet_rm() {
    # Quiet remove.
    # Updated 2019-10-22.
    rm -fr "$@" >/dev/null 2>&1
}



# R                                                                         {{{1
# ==============================================================================

_koopa_r_home() {
    # Get 'R_HOME', rather than exporting as global variable.
    # Updated 2019-06-27.
    _koopa_assert_is_installed R
    _koopa_assert_is_installed Rscript
    Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))'
}

_koopa_realpath() {
    # Locate the realpath of a program.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use '_koopa_which' instead.
    #
    # See also:
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # Examples:
    # _koopa_realpath bash
    # ## /usr/local/Cellar/bash/5.0.11/bin/bash
    #
    # Updated 2019-10-08.
    realpath "$(_koopa_which "$1")"
}

_koopa_remove_from_manpath() {
    # Remove directory from MANPATH.
    # Updated 2019-10-14.
    export MANPATH="${MANPATH//:$1/}"
}

_koopa_remove_from_path() {
    # Remove directory from PATH.
    #
    # Look into an improved POSIX method here.
    # This works for bash and ksh.
    # Note that this won't work on the first item in PATH.
    #
    # Alternate approach using sed:
    # > echo "$PATH" | sed "s|:${dir}||g"
    #
    # Updated 2019-10-14.
    export PATH="${PATH//:$1/}"
}

_koopa_rsync_flags() {
    # rsync flags.
    #
    # Useful flags:
    # -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
    # -z, --compress              compress file data during the transfer
    # -L, --copy-links            transform symlink into referent file/dir
    #     --delete-before         receiver deletes before xfer, not during
    # -h, --human-readable        output numbers in a human-readable format
    #     --iconv=CONVERT_SPEC    request charset conversion of filenames
    #     --progress              show progress during transfer
    #     --dry-run
    #     --one-file-system
    #     --acls --xattrs
    #     --iconv=utf-8,utf-8-mac
    #
    # Use --rsync-path="sudo rsync" to sync across machines with sudo.
    #
    # Updated 2019-10-15.
    echo "--archive --delete-before --human-readable --progress"
}



# S                                                                         {{{1
# ==============================================================================

_koopa_set_permissions() {
    # Set permissions on a koopa-related directory.
    # Generally used to reset the build prefix directory (e.g. '/usr/local').
    # Updated 2019-10-22.
    local path
    path="$1"
    if _koopa_is_shared
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi
    _koopa_prefix_chgrp "$path"
}

_koopa_shell() {
    # Note that this isn't necessarily the default shell ('$SHELL').
    # Updated 2019-06-27.
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

_koopa_strip_left() {
    # Strip pattern from left side (start) of string.
    #
    # Usage: _koopa_lstrip "string" "pattern"
    #
    # Example: _koopa_lstrip "The Quick Brown Fox" "The "
    #
    # Updated 2019-09-22.
    printf '%s\n' "${1##$2}"
}

_koopa_strip_right() {
    # Strip pattern from right side (end) of string.
    #
    # Usage: _koopa_rstrip "string" "pattern"
    #
    # Example: _koopa_rstrip "The Quick Brown Fox" " Fox"
    #
    # Updated 2019-09-22.
    printf '%s\n' "${1%%$2}"
}

_koopa_strip_trailing_slash() {
    # Strip trailing slash in file path string.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # Updated 2019-09-24.
    _koopa_strip_right "$1" "/"
}

_koopa_sub() {
    # Updated 2019-10-09.
    # See also: _koopa_gsub
    echo "$1" | sed -E "s/${2}/${3}/"
}



# T                                                                         {{{1
# ==============================================================================

_koopa_tmp_dir() {
    # Create temporary directory.
    #
    # See also:
    # - https://stackoverflow.com/questions/4632028
    # - https://gist.github.com/earthgecko/3089509
    #
    # Note: macOS requires 'env LC_CTYPE=C'.
    # Otherwise, you'll see this error: 'tr: Illegal byte sequence'.
    # This doesn't seem to work reliably, so using timestamp instead.
    #
    # Alternate approach:
    # > local unique
    # > local dir
    # > unique="$(date "+%Y%m%d-%H%M%S")"
    # > dir="/tmp/koopa-$(id -u)-${unique}"
    # > echo "$dir"
    #
    # Updated 2019-10-17.
    mktemp -d
}

_koopa_today_bucket() {
    # Create a dated file today bucket.
    # Also adds a '~/today' symlink for quick access.
    #
    # How to check if a symlink target matches a specific path:
    # https://stackoverflow.com/questions/19860345
    #
    # Useful link flags:
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    #
    # Updated 2019-09-28.
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
    ln -fns "${bucket_dir}/${bucket_today}" "$today_dir"
}

_koopa_trim_ws() {
    # Trim leading and trailing white-space from string.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # Usage: _koopa_trim_ws "   example   string    "
    #
    # Example: _koopa_trim_ws "    Hello,  World    "
    #
    # Updated 2019-09-22.
    trim="${1#${1%%[![:space:]]*}}"
    trim="${trim%${trim##*[![:space:]]}}"
    printf '%s\n' "$trim"
}



# U                                                                         {{{1
# ==============================================================================

_koopa_update_ldconfig() {
    # Update dynamic linker (LD) configuration.
    # Updated 2019-07-10.
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

_koopa_update_profile() {
    # Add shared 'zzz-koopa.sh' configuration file to '/etc/profile.d/'.
    # Updated 2019-10-15.
    local file
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    # Early return if config file already exists.
    file="/etc/profile.d/zzz-koopa.sh"
    if [ -f "$file" ]
    then
        printf "Note: '%s' exists.\n" "$file"
        return 0
    fi
    # Rename existing 'koopa.sh' file, if applicable.
    old_file="/etc/profile.d/koopa.sh"
    if [ -f "$old_file" ]
    then
        printf "Renaming '%s' to '%s'.\n" "$old_file" "$file"
        sudo mv -v "$old_file" "$file"
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

_koopa_update_r_config() {
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # Updated 2019-10-22.
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
    _koopa_set_permissions "$r_home"
    _koopa_r_javareconf
}

_koopa_update_shells() {
    # Update shell configuration.
    # Updated 2019-09-28.
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

_koopa_update_xdg_config() {
    # Update XDG configuration.
    # Path: '~/.config/koopa'.
    # Updated 2019-08-28.
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

_koopa_variable() {
    # Get version stored internally in versions.txt file.
    # Updated 2019-06-27.
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

_koopa_venv() {
    local env
    if [ -n "${VIRTUAL_ENV:-}" ]
    then
        # Strip out the path and just leave the env name.
        env="${VIRTUAL_ENV##*/}"
    else
        env=
    fi
    echo "$env"
}



# W                                                                         {{{1
# ==============================================================================

_koopa_warn_if_export() {
    # Warn if variable is exported in current shell session.
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # Updated 2019-10-16.
    local arg
    for arg in "$@"
    do
        if declare -x | grep -Eq "\b${arg}\b="
        then
            >&2 printf "Warning: '%s' is exported.\n" "$arg"
        fi
    done
    return 0
}

_koopa_which() {
    # Locate which program.
    #
    # Note that this intentionally doesn't resolve symlinks.
    # Use 'koopa_realpath' for that output instead.
    #
    # Example:
    # _koopa_which bash
    # ## /usr/local/bin/bash
    #
    # Updated 2019-10-08.
    command -v "$1"
}



# Z                                                                         {{{1
# ==============================================================================

_koopa_zsh_version() {
    # Updated 2019-08-18.
    zsh --version                                                              \
        | head -n 1                                                            \
        | cut -d ' ' -f 2
}



# Fallback support                                                          {{{1
# ==============================================================================

# Note that this doesn't support '-ne' flag.
# > if ! _koopa_is_installed echo
# > then
# >     echo() {
# >         printf "%s\n" "$1"
# >     }
# > fi

if ! _koopa_is_installed realpath
then
    realpath() {
        # Real path to file/directory on disk.
        #
        # Note that 'readlink -f' doesn't work on macOS.
        #
        # See also:
        # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/
        #       run_tests.sh
        #
        # Updated 2019-06-26.
        if [ "$(uname -s)" = "Darwin" ]
        then
            perl -MCwd -e 'print Cwd::abs_path shift' "$1"
        else
            readlink -f "$@"
        fi
    }
fi
