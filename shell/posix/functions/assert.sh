#!/bin/sh
# shellcheck disable=SC2039

_koopa_assert_are_identical() {                                           # {{{1
    # """
    # Assert that two strings are identical.
    # Updated 2020-02-04.
    # """
    if [ "${1:?}" != "${2:?}" ]
    then
        _koopa_stop "'${1}' is not identical to '${2}'."
    fi
    return 0
}

_koopa_assert_are_not_identical() {                                       # {{{1
    # """
    # Assert that two strings are not identical.
    # Updated 2020-02-04.
    # """
    if [ "${1:?}" = "${2:?}" ]
    then
        _koopa_stop "'${1}' is identical to '${2}'."
    fi
    return 0
}

_koopa_assert_has_args() {                                                # {{{1
    # """
    # Assert that the user has passed required arguments to a script.
    # Updated 2019-10-23.
    # """
    if [ "$#" -eq 0 ]
    then
        _koopa_stop "\
Required arguments missing.
Run with '--help' flag for usage details."
    fi
    return 0
}

_koopa_assert_has_no_args() {                                             # {{{1
    # """
    # Assert that the user has not passed any arguments to a script.
    # Updated 2019-10-23.
    # """
    if [ "$#" -ne 0 ]
    then
        _koopa_stop "\
Invalid argument: '${1}'.
Run with '--help' flag for usage details."
    fi
    return 0
}

_koopa_assert_has_file_ext() {                                            # {{{1
    # """
    # Assert that input contains a file extension.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if ! _koopa_has_file_ext "$arg"
        then
            _koopa_stop "No file extension: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_has_no_envs() {                                             # {{{1
    # """
    # Assert that conda and Python virtual environments aren't active.
    # Updated 2020-01-16.
    # """
    if ! _koopa_has_no_environments
    then
        _koopa_stop "\
Active environment detected.
       (conda and/or python venv)

Deactivate using:
    venv:  deactivate
    conda: conda deactivate

Deactivate venv prior to conda, otherwise conda python may be left in PATH."
    fi
    return 0
}

_koopa_assert_has_sudo() {                                                # {{{1
    # """
    # Assert that current user has sudo (admin) permissions.
    # Updated 2019-10-23.
    # """
    if ! _koopa_has_sudo
    then
        _koopa_stop "sudo is required."
    fi
    return 0
}

_koopa_assert_is_conda_active() {                                         # {{{1
    # """
    # Assert that a Conda environment is active.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_conda_active
    then
        _koopa_stop "No active Conda environment detected."
    fi
    return 0
}

_koopa_assert_is_current_version() {                                      # {{{1
    # """
    # Assert that programs are installed and current.
    # Updated 2020-01-24.
    # """
    for arg
    do
        if ! _koopa_is_installed "$arg"
        then
            local expected
            expected="$(_koopa_variable "$arg")"
            _koopa_stop "'${arg}' is not current; expecting '${expected}'."
        fi
    done
    return 0
}

_koopa_assert_is_debian() {                                               # {{{1
    # """
    # Assert that platform is Debian.
    # Updated 2019-10-25.
    # """
    if ! _koopa_is_debian
    then
        _koopa_stop "Debian is required."
    fi
    return 0
}

_koopa_assert_is_dir() {                                                  # {{{1
    # """
    # Assert that input is a directory.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ ! -d "$arg" ]
        then
            _koopa_stop "Not directory: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_executable() {                                           # {{{1
    # """
    # Assert that input is executable.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ ! -x "$arg" ]
        then
            _koopa_stop "Not executable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_existing() {                                             # {{{1
    # """
    # Assert that input exists on disk.
    # Updated 2020-01-16.
    #
    # Note that '-e' flag returns true for file, dir, or symlink.
    # """
    for arg
    do
        if [ ! -e "$arg" ]
        then
            _koopa_stop "Does not exist: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_fedora() {                                               # {{{1
    # """
    # Assert that platform is Fedora.
    # Updated 2019-10-25.
    # """
    if ! _koopa_is_fedora
    then
        _koopa_stop "Fedora is required."
    fi
    return 0
}

_koopa_assert_is_file() {                                                 # {{{1
    # """
    # Assert that input is a file.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ ! -f "$arg" ]
        then
            _koopa_stop "Not file: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_file_type() {                                            # {{{1
    # """
    # Assert that input matches a specified file type.
    # Updated 2020-01-12.
    #
    # Example: _koopa_assert_is_file_type "$x" "csv"
    # """
    local file
    file="${1:?}"
    local ext
    ext="${2:?}"
    _koopa_assert_is_file "$file"
    _koopa_assert_is_matching_regex "$file" "\.${ext}\$"
}

_koopa_assert_is_function() {                                             # {{{1
    # """
    # Assert that variable is a function.
    # @note Updated 2020-02-07.
    # """
    for arg
    do
        if ! _koopa_is_function "$arg"
        then
            _koopa_stop "Not function: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_git() {                                                  # {{{1
    # """
    # Assert that current directory is a git repo.
    # Updated 2020-02-10.
    # """
    if ! _koopa_is_git "$@"
    then
        _koopa_stop "Not a git repo."
    fi
    return 0
}

_koopa_assert_is_installed() {                                            # {{{1
    # """
    # Assert that programs are installed.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_stop "'${arg}' is not installed."
        fi
    done
    return 0
}

_koopa_assert_is_linux() {                                                # {{{1
    # """
    # Assert that platform is Linux.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_linux
    then
        _koopa_stop "Linux is required."
    fi
    return 0
}

_koopa_assert_is_macos() {                                                # {{{1
    # """
    # Assert that platform is macOS (Darwin).
    # Updated 2020-01-13.
    # """
    if ! _koopa_is_macos
    then
        _koopa_stop "macOS is required."
    fi
    return 0
}

_koopa_assert_is_non_existing() {                                         # {{{1
    # """
    # Assert that input does not exist on disk.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ -e "$arg" ]
        then
            _koopa_stop "Exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_dir() {                                              # {{{1
    # """
    # Assert that input is not a directory.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ -d "$arg" ]
        then
            _koopa_stop "Directory exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_file() {                                             # {{{1
    # """
    # Assert that input is not a file.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ -f "$arg" ]
        then
            _koopa_stop "File exists: '${1}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_installed() {                                        # {{{1
    # """
    # Assert that programs are not installed.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if _koopa_is_installed "$arg"
        then
            _koopa_stop "'${arg}' is installed."
        fi
    done
    return 0
}

_koopa_assert_is_rhel() {                                                 # {{{1
    # """
    # Assert that platform is RHEL.
    # Updated 2020-01-14.
    # """
    if ! _koopa_is_rhel
    then
        _koopa_stop "RHEL is required."
    fi
    return 0
}

_koopa_assert_is_rhel_7() {                                               # {{{1
    # """
    # Assert that platform is RHEL 7.
    # Updated 2020-01-14.
    # """
    if ! _koopa_is_rhel_7
    then
        _koopa_stop "RHEL 7 is required."
    fi
    return 0
}

_koopa_assert_is_rhel_8() {                                               # {{{1
    # """
    # Assert that platform is RHEL 8.
    # Updated 2020-01-14.
    # """
    if ! _koopa_is_rhel_8
    then
        _koopa_stop "RHEL 8 is required."
    fi
    return 0
}

_koopa_assert_is_not_root() {                                             # {{{1
    # """
    # Assert that current user is not root.
    # Updated 2019-12-17.
    # """
    if _koopa_is_root
    then
        _koopa_stop "root user detected."
    fi
    return 0
}

_koopa_assert_is_not_symlink() {                                          # {{{1
    # """
    # Assert that input is not a symbolic link.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ -L "$arg" ]
        then
            _koopa_stop "Symlink exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_r_package_installed() {                                  # {{{1
    # """
    # Assert that specific R packages are installed.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if ! _koopa_is_r_package_installed "${arg}"
        then
            _koopa_stop "'${arg}' R package is not installed."
        fi
    done
    return 0
}

_koopa_assert_is_readable() {                                             # {{{1
    # """
    # Assert that input is readable.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ ! -r "$arg" ]
        then
            _koopa_stop "Not readable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_root() {                                                 # {{{1
    # """
    # Assert that the current user is root.
    # Updated 2019-12-17.
    # """
    if ! _koopa_is_root
    then
        _koopa_stop "root user is required."
    fi
    return 0
}

_koopa_assert_is_set() {
    # """
    # Assert that variables are set (and not unbound).
    # Updated 2020-02-04.
    #
    # Intended to use inside of functions, where we can't be sure that 'set -u'
    # mode is set, which otherwise catches unbound variables.
    #
    # How to return bash variable name:
    # - https://unix.stackexchange.com/questions/129084
    #
    # Example:
    # _koopa_assert_is_set PATH MANPATH xxx
    # """
    for arg
    do
        if ! _koopa_is_set arg
        then
            _koopa_stop "'${arg}' is unset."
        fi
    done
    return 0
}

_koopa_assert_is_symlink() {                                              # {{{1
    # """
    # Assert that input is a symbolic link.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ ! -L "$arg" ]
        then
            _koopa_stop "Not symlink: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_venv_active() {                                          # {{{1
    # """
    # Assert that a Python virtual environment is active.
    # Updated 2019-10-23.
    # """
    _koopa_assert_is_installed pip
    if ! _koopa_is_venv_active
    then
        _koopa_stop "No active Python venv detected."
    fi
    return 0
}

_koopa_assert_is_writable() {                                             # {{{1
    # """
    # Assert that input is writable.
    # Updated 2020-01-16.
    # """
    for arg
    do
        if [ ! -r "$arg" ]
        then
            _koopa_stop "Not writable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_matching_fixed() {                                       # {{{1
    # """
    # Assert that input matches a fixed pattern.
    # Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    if ! _koopa_is_matching_fixed "$string" "$pattern"
    then
        _koopa_stop "'${string}' doesn't match fixed pattern '${pattern}'."
    fi
    return 0
}

_koopa_assert_is_matching_regex() {                                       # {{{1
    # """
    # Assert that input matches a regular expression pattern.
    # Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    if ! _koopa_is_matching_regex "$string" "$pattern"
    then
        _koopa_stop "'${string}' doesn't match regex pattern '${pattern}'."
    fi
    return 0
}

_koopa_assert_is_ubuntu() {                                               # {{{1
    # """
    # Assert that platform is Ubuntu.
    # Updated 2020-01-14.
    # """
    if ! _koopa_is_ubuntu
    then
        _koopa_stop "Ubuntu is required."
    fi
    return 0
}

_koopa_check_azure() {                                                    # {{{1
    # """
    # Check Azure VM integrity.
    # Updated 2019-10-31.
    # """
    _koopa_is_azure || return 0
    if [ -e "/mnt/resource" ]
    then
        _koopa_check_user "/mnt/resource" "root"
        _koopa_check_group "/mnt/resource" "root"
        _koopa_check_access_octal "/mnt/resource" "1777"
    fi
    _koopa_check_mount "/mnt/rdrive"
    return 0
}

_koopa_check_access_human() {                                             # {{{1
    # """
    # Check if file or directory has expected human readable access.
    # Updated 2020-01-12.
    # """
    local file
    file="${1:?}"
    local code
    code="${2:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist."
        return 1
    fi
    local access
    access="$(_koopa_stat_access_human "$file")"
    if [ "$access" != "$code" ]
    then
        _koopa_warning "'${file}' current access '${access}' is not '${code}'."
    fi
    return 0
}

_koopa_check_access_octal() {                                             # {{{1
    # """
    # Check if file or directory has expected octal access.
    # Updated 2020-01-12.
    # """
    local file
    file="${1:?}"
    local code
    code="${2:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist."
        return 1
    fi
    local access
    access="$(_koopa_stat_access_octal "$file")"
    if [ "$access" != "$code" ]
    then
        _koopa_warning "'${file}' current access '${access}' is not '${code}'."
    fi
    return 0
}

_koopa_check_group() {                                                    # {{{1
    # """
    # Check if file or directory has an expected group.
    # Updated 2020-01-12.
    # """
    local file
    file="${1:?}"
    local code
    code="${2:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist."
        return 1
    fi
    local group
    group="$(_koopa_stat_group "$file")"
    if [ "$group" != "$code" ]
    then
        _koopa_warning "'${file}' current group '${group}' is not '${code}'."
        return 1
    fi
    return 0
}

_koopa_check_mount() {                                                    # {{{1
    # """
    # Check if a drive is mounted.
    # Usage of find is recommended over ls here.
    # Updated 2020-01-16.
    # """
    local mnt
    mnt="${1:?}"
    if [ "$(find "$mnt" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]
    then
        _koopa_warning "'${mnt}' is unmounted."
        return 1
    fi
    return 0
}

_koopa_check_user() {                                                     # {{{1
    # """
    # Check if file or directory is owned by an expected user.
    # Updated 2020-01-13.
    # """
    local file
    file="${1:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist on disk."
        return 1
    fi
    file="$(realpath "$file")"
    local expected_user
    expected_user="${2:?}"
    local current_user
    current_user="$(_koopa_stat_user "$file")"
    if [ "$current_user" != "$expected_user" ]
    then
        _koopa_warning "'${file}' user '${current_user}' is not \
'${expected_user}'."
        return 1
    fi
    return 0
}

_koopa_exit_if_dir() {                                                    # {{{1
    # """
    # Exit with note if directory exists.
    # Updated 2020-01-22.
    # """
    for arg
    do
        if [ -d "$arg" ]
        then
            _koopa_note "Directory exists: '${arg}'."
            exit 0
        fi
    done
    return 0
}

_koopa_exit_if_docker() {                                                 # {{{1
    # """
    # Exit with note if running inside Docker.
    # Updated 2020-01-22.
    # """
    if _koopa_is_docker
    then
        _koopa_note "Not supported when running inside Docker."
        exit 0
    fi
    return 0
}

_koopa_exit_if_exists() {                                                 # {{{1
    # """
    # Exit with note if any file type exists.
    # Updated 2020-01-28.
    # """
    for arg
    do
        if [ -e "$arg" ]
        then
            _koopa_note "Exists: '${arg}'."
            exit 0
        fi
    done
    return 0
}

_koopa_exit_if_installed() {                                              # {{{1
    # """
    # Exit with note if an app is installed.
    # Updated 2020-02-06.
    # """
    for arg
    do
        if _koopa_is_installed "$arg"
        then
            local where
            where="$(_koopa_which_realpath "$arg")"
            _koopa_note "'${arg}' is installed at '${where}'."
            exit 0
        fi
    done
    return 0
}

_koopa_exit_if_not_installed() {                                          # {{{1
    # """
    # Exit with note if an app is not installed.
    # Updated 2020-01-31.
    # """
    for arg
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_note "'${arg}' is not installed."
            exit 0
        fi
    done
    return 0
}

_koopa_has_file_ext() {                                                   # {{{1
    # """
    # Does the input contain a file extension?
    # Updated 2020-01-12.
    #
    # Simply looks for a "." and returns true/false.
    # """
    local file
    file="${1:?}"
    echo "$file" | grep -q "\."
}

_koopa_has_no_environments() {                                            # {{{1
    # """
    # Detect activation of virtual environments.
    # Updated 2019-10-20.
    # """
    _koopa_is_conda_active && return 1
    _koopa_is_venv_active && return 1
    return 0
}

# Also defined in koopa installer.
_koopa_has_passwordless_sudo() {                                          # {{{1
    # """
    # Check if sudo is active or doesn't require a password.
    # Updated 2020-02-05.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    _koopa_is_installed sudo || return 1
    sudo -n true 2>/dev/null && return 0
    return 1
}

# Also defined in koopa installer.
_koopa_has_sudo() {                                                       # {{{1
    # """
    # Check that current user has administrator (sudo) permission.
    # Updated 2020-02-05.
    #
    # This check is hanging on an CPI AWS Ubuntu EC2 instance, I think due to
    # 'groups' taking a long time to return for domain users.
    #
    # Avoid prompting with '-n, --non-interactive', but note that this isn't
    # supported on all systems.
    #
    # Note that use of 'sudo -v' does not work consistently across platforms.
    #
    # Alternate approach:
    # > sudo -l
    #
    # List all users with sudo access:
    # > getent group sudo
    #
    # - macOS: admin
    # - Debian: sudo
    # - Fedora: wheel
    #
    # See also:
    # - https://serverfault.com/questions/364334
    # - https://linuxhandbook.com/check-if-user-has-sudo-rights/
    # """
    # Always return true for root user.
    [ "$(id -u)" -eq 0 ] && return 0
    # Return false if 'sudo' program is not installed.
    _koopa_is_installed sudo || return 1
    # Early return true if user has passwordless sudo enabled.
    _koopa_has_passwordless_sudo && return 0
    # This step is slow for Active Directory domain user accounts on Ubuntu.
    _koopa_assert_is_installed grep groups
    groups | grep -Eq "\b(admin|root|sudo|wheel)\b"
}

_koopa_invalid_arg() {                                                    # {{{1
    # """
    # Error on invalid argument.
    # Updated 2019-10-23.
    # """
    local arg
    arg="${1:?}"
    _koopa_stop "Invalid argument: '${arg}'."
}

_koopa_is_alias() {                                                       # {{{1
    # """
    # Is the specified argument an alias?
    # Updated 2020-02-06.
    #
    # @example
    # _koopa_is_alias R
    # """
    local cmd
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    local str
    str="$(type "$cmd")"
    local shell
    shell="$(_koopa_shell)"
    case "$shell" in
        bash)
            pattern="is aliased to"
            ;;
        zsh)
            pattern="is an alias for"
            ;;
    esac
    _koopa_is_matching_fixed "$str" "$pattern"
}

_koopa_is_aws() {                                                         # {{{1
    # """
    # Is the current session running on AWS?
    # Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = "aws" ]
}

_koopa_is_amzn() {                                                        # {{{1
    # """
    # Is the operating system Amazon Linux?
    # Updated 2020-01-21.
    # """
    [ "$(_koopa_os_id)" = "amzn" ]
}

_koopa_is_azure() {                                                       # {{{1
    # """
    # Is the current session running on Microsoft Azure?
    # Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = "azure" ]
}

_koopa_is_conda_active() {                                                # {{{1
    # """
    # Is there a Conda environment active?
    # Updated 2019-10-20.
    # """
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

_koopa_is_current_version() {                                             # {{{1
    # """
    # Is the installed program current?
    # Updated 2020-02-07.
    # """
    local app
    app="${1:?}"
    local expected
    expected="$(_koopa_variable "$app")"
    echo "$expected"
    local actual
    actual="$(_koopa_get_version "$app")"
    echo "$actual"
    [ "$actual" == "$expected" ]
}

_koopa_is_debian() {                                                      # {{{1
    # """
    # Is the operating system Debian?
    # Updated 2019-10-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "debian" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}

_koopa_is_docker() {                                                      # {{{1
    # """
    # Is the current shell running inside Docker?
    # Updated 2020-01-22.
    #
    # https://stackoverflow.com/questions/23513045
    # """
    local file
    file="/proc/1/cgroup"
    [ -f "$file" ] || return 1
    grep -q ':/docker/' "$file"
}

_koopa_is_fedora() {                                                      # {{{1
    # """
    # Is the operating system Fedora?
    # Updated 2019-10-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "fedora" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}

_koopa_is_file_system_case_sensitive() {                                  # {{{1
    # """
    # Is the file system case sensitive?
    # Updated 2019-10-21.
    #
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # """
    touch ".tmp.checkcase" ".tmp.checkCase"
    count="$(find . -maxdepth 1 -iname ".tmp.checkcase" | wc -l)"
    _koopa_quiet_rm .tmp.check* 
    if [ "$count" -eq 2 ]
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_function() {                                                    # {{{1
    # """
    # Check if variable is a function.
    # @note Updated 2020-02-07.
    #
    # @seealso
    # https://stackoverflow.com/questions/85880
    # """
    local fun
    fun="${1:?}"
    case "$(_koopa_shell)" in
        bash)
            [ "$(type -t "$fun")" == "function" ]
            ;;
        zsh)
            _koopa_is_matching_fixed "$(type "$fun")" "is a shell function"
            ;;
    esac
}

_koopa_is_git() {                                                         # {{{1
    # """
    # Is the directory a git repository?
    # Updated 2020-02-10.
    #
    # See also:
    # - https://stackoverflow.com/questions/2180270
    # """
    _koopa_assert_is_installed git
    local dir
    dir="$(realpath "${1:-}")"
    [ -d "${dir}/.git" ] || return 1
    (
        cd "$dir" || return 1
        if git rev-parse --git-dir > /dev/null 2>&1
        then
            return 0
        else
            return 1
        fi
    )
}

_koopa_is_git_clean() {                                                   # {{{1
    # """
    # Is the git repo clean, or does it have unstaged changes?
    # Updated 2020-02-10.
    #
    # See also:
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    _koopa_assert_is_installed git
    dir="$(realpath "${1:-}")"
    (
        cd "$dir" || return 1
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
    )
    return 0
}

# Also defined in koopa installer.
_koopa_is_installed() {                                                   # {{{1
    # """
    # Is the requested program name installed?
    # Updated 2019-10-02.
    # """
    command -v "$1" >/dev/null
}

_koopa_is_interactive() {                                                 # {{{1
    # """
    # Is the current shell interactive?
    # Updated 2019-06-21.
    # """
    echo "$-" | grep -q "i"
}

# Also defined in koopa installer.
_koopa_is_linux() {                                                       # {{{1
    # """
    # Is the current operating system Linux?
    # Updated 2020-02-05.
    # """
    [ "$(uname -s)" = "Linux" ]
}

# Also defined in koopa installer.
_koopa_is_local_install() {                                               # {{{1
    # """
    # Is koopa installed only for the current user?
    # Updated 2019-06-25.
    # """
    echo "$KOOPA_PREFIX" | grep -Eq "^${HOME}"
}

_koopa_is_login() {                                                       # {{{1
    # """
    # Is the current shell a login shell?
    # Updated 2019-08-14.
    # """
    echo "$0" | grep -Eq "^-"
}

_koopa_is_login_bash() {                                                  # {{{1
    # """
    # Is the current shell a login bash shell?
    # Updated 2019-06-21.
    # """
    [ "$0" = "-bash" ]
}

_koopa_is_login_zsh() {                                                   # {{{1
    # """
    # Is the current shell a login zsh shell?
    # Updated 2019-06-21.
    # """
    [ "$0" = "-zsh" ]
}

_koopa_is_macos() {                                                       # {{{1
    # """
    # Is the operating system macOS (Darwin)?
    # Updated 2020-01-13.
    # """
    [ "$(uname -s)" = "Darwin" ]
}

_koopa_is_matching_fixed() {                                              # {{{1
    # """
    # Does the input match a fixed string?
    # Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    echo "$string" | grep -Fq "$pattern"
}

_koopa_is_matching_regex() {                                              # {{{1
    # """
    # Does the input match a regular expression?
    # Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    echo "$string" | grep -Eq "$pattern"
}

_koopa_is_powerful() {                                                    # {{{1
    # """
    # Is the current machine powerful?
    # Updated 2019-11-22.
    # """
    local cores
    cores="$(_koopa_cpu_count)"
    if [ "$cores" -ge 7 ]
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_r_package_installed() {                                         # {{{1
    # """
    # Is the requested R package installed?
    # Updated 2019-10-20.
    # """
    _koopa_is_installed R || return 1
    Rscript -e "\"$1\" %in% rownames(utils::installed.packages())" \
        | grep -q "TRUE"
}

_koopa_is_rhel() {                                                        # {{{1
    # """
    # Is the operating system RHEL?
    # Updated 2019-12-09.
    # """
    _koopa_is_fedora || return 1
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "rhel" && return 0
    grep "ID_LIKE=" /etc/os-release | grep -q "rhel" && return 0
    return 1
}

_koopa_is_rhel_7() {                                                      # {{{1
    # """
    # Is the operating system RHEL 7?
    # Updated 2019-11-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep -q 'ID="rhel"' /etc/os-release || return 1
    grep -q 'VERSION_ID="7' /etc/os-release || return 1
    return 0
}

_koopa_is_rhel_8() {                                                      # {{{1
    # """
    # Is the operating system RHEL 8?
    # Updated 2019-11-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep -q 'ID="rhel"' /etc/os-release || return 1
    grep -q 'VERSION_ID="8' /etc/os-release || return 1
    return 0
}

_koopa_is_remote() {                                                      # {{{1
    # """
    # Is the current shell session a remote connection over SSH?
    # Updated 2019-06-25.
    # """
    [ -n "${SSH_CONNECTION:-}" ]
}

_koopa_is_root() {                                                        # {{{1
    # """
    # Is the current user root?
    # Updated 2019-12-17
    # """
    [ "$(id -u)" -eq 0 ]
}

# Also defined in koopa installer.
_koopa_is_shared_install() {                                              # {{{1
    # """
    # Is koopa installed for all users (shared)?
    # Updated 2019-06-25.
    # """
    ! _koopa_is_local_install
}

_koopa_is_set() {                                                         # {{{1
    # """
    # Is the variable set and non-empty?
    # @note Updated 2020-02-07.
    #
    # Passthrough of empty strings is bad practice in shell scripting.
    #
    # @seealso
    # https://stackoverflow.com/questions/3601515
    # """
    [ -n "${1:-}" ]
}

_koopa_is_setopt_nounset() {                                              # {{{1
    # """
    # Is shell running in 'nounset' variable mode?
    # Updated 2020-01-24.
    #
    # Many activation scripts, including Perlbrew and others have unset
    # variables that can cause the shell session to exit.
    #
    # How to enable:
    # > set -o nounset
    # > set -u
    #
    # Bash:
    # shopt -o (arg?)
    # Enabled: 'nounset [...] on'.
    #
    # shopt -op (arg?)
    # Enabled: 'set -o nounset'.
    #
    # Zsh:
    # setopt
    # Enabled: 'nounset'.
    # """
    local shell
    shell="$(_koopa_shell)"
    case "$shell" in
        bash)
            # > shopt -op nounset | grep -q 'set -o nounset'
            shopt -oq nounset
            ;;
        zsh)
            setopt | grep -q 'nounset'
            ;;
        *)
            _koopa_stop "Unknown error."
            ;;
    esac
}

_koopa_is_ubuntu() {                                                      # {{{1
    # """
    # Is the operating system Ubuntu?
    # Updated 2020-01-14.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "ubuntu" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "ubuntu"
}

_koopa_is_venv_active() {                                                 # {{{1
    # """
    # Is there a Python virtual environment active?
    # Updated 2019-10-20.
    # """
    [ -n "${VIRTUAL_ENV:-}" ]
}

_koopa_missing_arg() {                                                    # {{{1
    # """
    # Error on a missing argument.
    # Updated 2019-10-23.
    # """
    _koopa_stop "Missing required argument."
}

_koopa_run_if_installed() {                                               # {{{1
    # """
    # Run program(s) if installed.
    # Updated 2020-02-06.
    # """
    for arg
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_note "Skipping '${arg}'."
            continue
        fi
        local exe
        exe="$(_koopa_which_realpath "$arg")"
        "$exe"
    done
    return 0
}

_koopa_warn_if_export() {                                                 # {{{1
    # """
    # Warn if variable is exported in current shell session.
    # Updated 2019-10-27.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    local arg
    for arg in "$@"
    do
        if declare -x | grep -Eq "\b${arg}\b="
        then
            _koopa_warning "'${arg}' is exported."
        fi
    done
    return 0
}
