#!/bin/sh
# shellcheck disable=SC2039



# A                                                                         {{{1
# ==============================================================================

_koopa_add_bins_to_path() {
    # Add nested `bin/` and `sbin/` directories to PATH.
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
    # Experimental: working method to improve pandoc and texlive on RHEL 7.
    # Updated 2019-09-12.
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

_koopa_add_to_manpath_end() {
    # Add directory to end of MANPATH.
    # Updated 2019-10-11.
    [ ! -d "$1" ] && return 0
    echo "$MANPATH" | grep -q "$1" && return 0
    export MANPATH="${MANPATH}:${1}"
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
    # Updated 2019-10-12.
    if ! _koopa_has_no_environments
    then
        >&2 cat << EOF
Error: Active environment detected.
       (conda and/or python venv)

Deactivate using:
    conda: conda deactivate
    venv:  deactivate
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
    # Updated 2019-09-24.
    _koopa_assert_is_file "$1"
    _koopa_assert_matches_pattern "$1" "\.${2}\$"
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

_koopa_assert_matches_pattern() {
    # Assert that input matches a pattern.
    #
    # Bash alternative:
    # > [[ ! $1 =~ $2 ]]
    #
    # Updated 2019-09-24.
    if ! echo "$1" | grep -q "$2"
    then
        >&2 printf "Error: '%s' doesn't match pattern '%s'.\n" "$1" "$2"
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
    bash --version | \
        head -n 1 | \
        cut -d ' ' -f 4 | \
        cut -d '(' -f 1
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

_koopa_conda_env() {
    # Conda environment name.
    # Updated 2019-10-13.
    echo "${CONDA_DEFAULT_ENV:-}"
}

_koopa_conda_prefix() {
    # Updated 2019-09-27.
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
    # Updated 2019-08-15.
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
    df "$disk" | \
        head -n 2  | \
        sed -n '2p' | \
        grep -Eo "([.0-9]+%)" | \
        head -n 1 | \
        sed 's/%$//'
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
    # Updated 2019-09-24.
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

_koopa_force_add_to_path_end() {
    # Updated 2019-06-27.
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_end "$dir"
}

_koopa_force_add_to_path_start() {
    # Updated 2019-06-27.
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_start "$dir"
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
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    #
    # Updated 2019-10-13.
    _koopa_is_git || return 1
    git symbolic-ref --short -q HEAD
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
    # Updated 2019-06-25.
    [ -x "$(command -v conda)" ] && [ -n "${CONDA_PREFIX:-}" ] && return 1
    [ -x "$(command -v deactivate)" ] && return 1
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
    # Updated 2019-09-10.
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

_koopa_is_darwin() {
    # Is the operating system Darwin (macOS)?
    # Updated 2019-06-22.
    [ "$(uname -s)" = "Darwin" ]
}

_koopa_is_git() {
    # Is the current working directory a git repository?
    #
    # See also:
    # - https://stackoverflow.com/questions/2180270
    #
    # Updated 2019-10-13.
    if git rev-parse --git-dir > /dev/null 2>&1
    then
        # TRUE
        return 0
    else
        # FALSE
        return 1
    fi
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
    grep "ID="      /etc/os-release | grep -q "debian" ||
    grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}

_koopa_is_linux_fedora() {
    # Updated 2019-06-24.
    [ -f /etc/os-release ] || return 1
    grep "ID="      /etc/os-release | grep -q "fedora" ||
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
    wc -l "$1" | \
    xargs | \
    cut -d ' ' -f 1
}



# M                                                                         {{{1
# ==============================================================================

_koopa_macos_app_version() {
    # Extract the version of a macOS application.
    # Updated 2019-09-28.
    _koopa_assert_is_darwin
    plutil -p "/Applications/${1}.app/Contents/Info.plist" | \
        grep CFBundleShortVersionString |
        awk -F ' => ' '{print $2}' |
        tr -d '"'
}

_koopa_macos_version() {
    # macOS version string.
    # Updated 2019-08-17.
    _koopa_assert_is_darwin
    printf "%s %s (%s)\n" \
        "$(sw_vers -productName)" \
        "$(sw_vers -productVersion)" \
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
    # Updated 2019-08-16.
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
    # Updated 2019-10-13.
    _koopa_is_git || return 0
    local branch
    branch="$(_koopa_git_branch)"
    printf " git:%s\n" "$branch"
}

_koopa_prompt_os() {
    # Get the operating system information.
    # Updated 2019-10-13.
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
    # Avoid using `[[ =~ ]]` in sh config files.
    # `expr` is faster than using `case`.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    #
    # Updated 2019-10-08.
    expr "$1" : "$2" 1>/dev/null
}



# R                                                                         {{{1
# ==============================================================================

_koopa_r_home() {
    # Get `R_HOME`, rather than exporting as global variable.
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
    # Updated 2019-07-10.
    local dir
    dir="$1"
    export PATH="${PATH//:$dir/}"
}

_koopa_rsync_flags() {
    # Improved rsync default flags.
    # Updated 2019-06-21.
    echo "--archive --copy-links --delete-before --human-readable --progress"
}



# S                                                                         {{{1
# ==============================================================================

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

_koopa_today_bucket() {
    # Create a dated file today bucket.
    # Also adds a `~/today` symlink for quick access.
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
    # Add shared `koopa.sh` configuration file to `/etc/profile.d/`.
    # Updated 2019-06-29.
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

_koopa_update_r_config() {
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # Updated 2019-09-28.
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
    zsh --version | \
        head -n 1 | \
        cut -d ' ' -f 2
}



# Fallback support                                                          {{{1
# ==============================================================================

if _koopa_is_installed echo
then
    echo() {
        printf "%s\n" "$1"
    }
fi

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
