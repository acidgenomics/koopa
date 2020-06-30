#!/bin/sh
# shellcheck disable=SC2039

_koopa_assert_are_identical() { # {{{1
    # """
    # Assert that two strings are identical.
    # @note Updated 2020-02-04.
    # """
    if [ "${1:?}" != "${2:?}" ]
    then
        _koopa_stop "'${1}' is not identical to '${2}'."
    fi
    return 0
}

_koopa_assert_are_not_identical() { # {{{1
    # """
    # Assert that two strings are not identical.
    # @note Updated 2020-02-04.
    # """
    if [ "${1:?}" = "${2:?}" ]
    then
        _koopa_stop "'${1}' is identical to '${2}'."
    fi
    return 0
}

_koopa_assert_has_args() { # {{{1
    # """
    # Assert that the user has passed required arguments to a script.
    # @note Updated 2019-10-23.
    # """
    if [ "$#" -eq 0 ]
    then
        _koopa_stop "\
Required arguments missing.
Run with '--help' flag for usage details."
    fi
    return 0
}

_koopa_assert_has_file_ext() { # {{{1
    # """
    # Assert that input contains a file extension.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg in "$@"
    do
        if ! _koopa_has_file_ext "$arg"
        then
            _koopa_stop "No file extension: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_has_gnu_binutils() {  #{{{1
    # """
    # Assert that GNU binutils is installed.
    # @note Updated 2020-04-27.
    # """
    if ! _koopa_has_gnu_binutils
    then
        _koopa_stop "GNU binutils is not installed."
    fi
    return 0
}

_koopa_assert_has_gnu_coreutils() {  #{{{1
    # """
    # Assert that GNU coreutils is installed.
    # @note Updated 2020-04-27.
    # """
    if ! _koopa_has_gnu_coreutils
    then
        _koopa_stop "GNU coreutils is not installed."
    fi
    return 0
}

_koopa_assert_has_gnu_findutils() {  #{{{1
    # """
    # Assert that GNU findutils is installed.
    # @note Updated 2020-04-27.
    # """
    if ! _koopa_has_gnu_findutils
    then
        _koopa_stop "GNU findutils is not installed."
    fi
    return 0
}

_koopa_assert_has_gnu_sed() {  #{{{1
    # """
    # Assert that GNU sed is installed.
    # @note Updated 2020-04-27.
    # """
    if ! _koopa_has_gnu_sed
    then
        _koopa_stop "GNU sed is not installed."
    fi
    return 0
}

_koopa_assert_has_gnu_tar() {  #{{{1
    # """
    # Assert that GNU tar is installed.
    # @note Updated 2020-04-27.
    # """
    if ! _koopa_has_gnu_tar
    then
        _koopa_stop "GNU tar is not installed."
    fi
    return 0
}

_koopa_assert_has_no_args() { # {{{1
    # """
    # Assert that the user has not passed any arguments to a script.
    # @note Updated 2019-10-23.
    # """
    if [ "$#" -ne 0 ]
    then
        _koopa_stop "\
Invalid argument: '${1}'.
Run with '--help' flag for usage details."
    fi
    return 0
}

_koopa_assert_has_no_envs() { # {{{1
    # """
    # Assert that conda and Python virtual environments aren't active.
    # @note Updated 2020-01-16.
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

_koopa_assert_has_sudo() { # {{{1
    # """
    # Assert that current user has sudo (admin) permissions.
    # @note Updated 2019-10-23.
    # """
    if ! _koopa_has_sudo
    then
        _koopa_stop "sudo is required."
    fi
    return 0
}

_koopa_assert_is_alpine() { # {{{1
    # """
    # Assert that platform is Alpine.
    # @note Updated 2020-02-27.
    # """
    if ! _koopa_is_alpine
    then
        _koopa_stop "Alpine is required."
    fi
    return 0
}

_koopa_assert_is_arch() { # {{{1
    # """
    # Assert that platform is Arch.
    # @note Updated 2020-02-27.
    # """
    if ! _koopa_is_arch
    then
        _koopa_stop "Arch is required."
    fi
    return 0
}

_koopa_assert_is_cellar() { # {{{1
    # """
    # Assert that input is a cellarized program.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg in "$@"
    do
        if ! _koopa_is_cellar "$arg"
        then
            _koopa_stop "Not in cellar: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_conda_active() { # {{{1
    # """
    # Assert that a Conda environment is active.
    # @note Updated 2019-10-23.
    # """
    if ! _koopa_is_conda_active
    then
        _koopa_stop "No active Conda environment detected."
    fi
    return 0
}

_koopa_assert_is_current_version() { # {{{1
    # """
    # Assert that programs are installed and current.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
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

_koopa_assert_is_debian() { # {{{1
    # """
    # Assert that platform is Debian.
    # @note Updated 2019-10-25.
    # """
    if ! _koopa_is_debian
    then
        _koopa_stop "Debian is required."
    fi
    return 0
}

_koopa_assert_is_dir() { # {{{1
    # """
    # Assert that input is a directory.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -d "$arg" ]
        then
            _koopa_stop "Not directory: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_executable() { # {{{1
    # """
    # Assert that input is executable.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -x "$arg" ]
        then
            _koopa_stop "Not executable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_existing() { # {{{1
    # """
    # Assert that input exists on disk.
    # @note Updated 2020-02-16.
    #
    # Note that '-e' flag returns true for file, dir, or symlink.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -e "$arg" ]
        then
            _koopa_stop "Does not exist: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_fedora() { # {{{1
    # """
    # Assert that platform is Fedora.
    # @note Updated 2019-10-25.
    # """
    if ! _koopa_is_fedora
    then
        _koopa_stop "Fedora is required."
    fi
    return 0
}

_koopa_assert_is_file() { # {{{1
    # """
    # Assert that input is a file.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -f "$arg" ]
        then
            _koopa_stop "Not file: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_file_type() { # {{{1
    # """
    # Assert that input matches a specified file type.
    # @note Updated 2020-01-12.
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

_koopa_assert_is_function() { # {{{1
    # """
    # Assert that variable is a function.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_function "$arg"
        then
            _koopa_stop "Not function: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_git_toplevel() { # {{{1
    # """
    # Assert that current directory is a git repo.
    # @note Updated 2020-04-29.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        arg="$(realpath "$arg")"
        if ! _koopa_is_git_toplevel "$arg"
        then
            _koopa_stop "Not a git repo: '$arg'."
        fi
    done
    return 0
}

_koopa_assert_is_github_ssh_enabled() { # {{{1
    # """
    # Assert that current user has SSH key access to GitHub.
    # @note Updated 2020-02-11.
    # """
    if ! _koopa_is_github_ssh_enabled
    then
        _koopa_stop "GitHub SSH access is not configured correctly."
    fi
    return 0
}

_koopa_assert_is_gitlab_ssh_enabled() { # {{{1
    # """
    # Assert that current user has SSH key access to GitLab.
    # @note Updated 2020-02-11.
    # """
    if ! _koopa_is_gitlab_ssh_enabled
    then
        _koopa_stop "GitLab SSH access is not configured correctly."
    fi
    return 0
}

_koopa_assert_is_installed() { # {{{1
    # """
    # Assert that programs are installed.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_stop "'${arg}' is not installed."
        fi
    done
    return 0
}

_koopa_assert_is_kali() { # {{{1
    # """
    # Assert that platform is Kali Linux.
    # @note Updated 2020-02-27.
    # """
    if ! _koopa_is_kali
    then
        _koopa_stop "Kali is required."
    fi
    return 0
}

_koopa_assert_is_linux() { # {{{1
    # """
    # Assert that platform is Linux.
    # @note Updated 2019-10-23.
    # """
    if ! _koopa_is_linux
    then
        _koopa_stop "Linux is required."
    fi
    return 0
}

_koopa_assert_is_macos() { # {{{1
    # """
    # Assert that platform is macOS (Darwin).
    # @note Updated 2020-01-13.
    # """
    if ! _koopa_is_macos
    then
        _koopa_stop "macOS is required."
    fi
    return 0
}

_koopa_assert_is_non_existing() { # {{{1
    # """
    # Assert that input does not exist on disk.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ -e "$arg" ]
        then
            _koopa_stop "Exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_nonzero_file() { # {{{1
    # """
    # Assert that input is a non-zero file.
    # @note Updated 2020-03-06.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -s "$arg" ]
        then
            _koopa_stop "Not non-zero file: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_dir() { # {{{1
    # """
    # Assert that input is not a directory.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ -d "$arg" ]
        then
            _koopa_stop "Directory exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_file() { # {{{1
    # """
    # Assert that input is not a file.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ -f "$arg" ]
        then
            _koopa_stop "File exists: '${1}'."
        fi
    done
    return 0
}

_koopa_assert_is_not_installed() { # {{{1
    # """
    # Assert that programs are not installed.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if _koopa_is_installed "$arg"
        then
            _koopa_stop "'${arg}' is installed."
        fi
    done
    return 0
}

_koopa_assert_is_opensuse() { # {{{1
    # """
    # Assert that platform is openSUSE.
    # @note Updated 2020-02-27.
    # """
    if ! _koopa_is_opensuse
    then
        _koopa_stop "openSUSE is required."
    fi
    return 0
}

_koopa_assert_is_rhel() { # {{{1
    # """
    # Assert that platform is RHEL.
    # @note Updated 2020-01-14.
    # """
    if ! _koopa_is_rhel
    then
        _koopa_stop "RHEL is required."
    fi
    return 0
}

_koopa_assert_is_rhel_7() { # {{{1
    # """
    # Assert that platform is RHEL 7.
    # @note Updated 2020-01-14.
    # """
    if ! _koopa_is_rhel_7
    then
        _koopa_stop "RHEL 7 is required."
    fi
    return 0
}

_koopa_assert_is_rhel_8() { # {{{1
    # """
    # Assert that platform is RHEL 8.
    # @note Updated 2020-01-14.
    # """
    if ! _koopa_is_rhel_8
    then
        _koopa_stop "RHEL 8 is required."
    fi
    return 0
}

_koopa_assert_is_not_root() { # {{{1
    # """
    # Assert that current user is not root.
    # @note Updated 2019-12-17.
    # """
    if _koopa_is_root
    then
        _koopa_stop "root user detected."
    fi
    return 0
}

_koopa_assert_is_not_symlink() { # {{{1
    # """
    # Assert that input is not a symbolic link.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ -L "$arg" ]
        then
            _koopa_stop "Symlink exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_python_package_installed() { # {{{1
    # """
    # Assert that specific Python packages are installed.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_python_package_installed "${arg}"
        then
            _koopa_stop "'${arg}' Python package is not installed."
        fi
    done
    return 0
}

_koopa_assert_is_r_package_installed() { # {{{1
    # """
    # Assert that specific R packages are installed.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_r_package_installed "${arg}"
        then
            _koopa_stop "'${arg}' R package is not installed."
        fi
    done
    return 0
}

_koopa_assert_is_readable() { # {{{1
    # """
    # Assert that input is readable.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -r "$arg" ]
        then
            _koopa_stop "Not readable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_root() { # {{{1
    # """
    # Assert that the current user is root.
    # @note Updated 2019-12-17.
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
    # @note Updated 2020-03-04.
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
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_set "$arg"
        then
            _koopa_stop "'${arg}' is unset."
        fi
    done
    return 0
}

_koopa_assert_is_symlink() { # {{{1
    # """
    # Assert that input is a symbolic link.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -L "$arg" ]
        then
            _koopa_stop "Not symlink: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_venv_active() { # {{{1
    # """
    # Assert that a Python virtual environment is active.
    # @note Updated 2019-10-23.
    # """
    _koopa_assert_is_installed pip
    if ! _koopa_is_venv_active
    then
        _koopa_stop "No active Python venv detected."
    fi
    return 0
}

_koopa_assert_is_writable() { # {{{1
    # """
    # Assert that input is writable.
    # @note Updated 2020-02-16.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ ! -r "$arg" ]
        then
            _koopa_stop "Not writable: '${arg}'."
        fi
    done
    return 0
}

_koopa_assert_is_matching_fixed() { # {{{1
    # """
    # Assert that input matches a fixed pattern.
    # @note Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    if ! _koopa_str_match "$string" "$pattern"
    then
        _koopa_stop "'${string}' doesn't match fixed pattern '${pattern}'."
    fi
    return 0
}

_koopa_assert_is_matching_regex() { # {{{1
    # """
    # Assert that input matches a regular expression pattern.
    # @note Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    if ! _koopa_str_match_regex "$string" "$pattern"
    then
        _koopa_stop "'${string}' doesn't match regex pattern '${pattern}'."
    fi
    return 0
}

_koopa_assert_is_ubuntu() { # {{{1
    # """
    # Assert that platform is Ubuntu.
    # @note Updated 2020-01-14.
    # """
    if ! _koopa_is_ubuntu
    then
        _koopa_stop "Ubuntu is required."
    fi
    return 0
}
