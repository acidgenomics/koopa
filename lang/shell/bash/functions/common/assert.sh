#!/usr/bin/env bash

koopa::assert_are_identical() { # {{{1
    # """
    # Assert that two strings are identical.
    # @note Updated 2020-07-07.
    # """
    koopa::assert_has_args_eq "$#" 2
    if [[ "${1:?}" != "${2:?}" ]]
    then
        koopa::stop "'${1}' is not identical to '${2}'."
    fi
    return 0
}

koopa::assert_are_not_identical() { # {{{1
    # """
    # Assert that two strings are not identical.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_args_eq "$#" 2
    if [[ "${1:?}" == "${2:?}" ]]
    then
        koopa::stop "'${1}' is identical to '${2}'."
    fi
    return 0
}

koopa::assert_has_args() { # {{{1
    # """
    # Assert that non-zero arguments have been passed.
    # @note Updated 2022-02-15.
    # Does not check for empty strings.
    # """
    if [[ "$#" -ne 1 ]]
    then
        koopa::stop \
            '"koopa::assert_has_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -eq 0 ]]
    then
        koopa::stop 'Required arguments missing.'
    fi
    return 0
}

koopa::assert_has_args_eq() { # {{{1
    # """
    # Assert that an expected number of arguments have been passed.
    # @note Updated 2020-07-03.
    # """
    if [[ "$#" -ne 2 ]]
    then
        koopa::stop '"koopa::assert_has_args_eq" requires 2 args.'
    fi
    if [[ "${1:?}" -ne "${2:?}" ]]
    then
        koopa::stop 'Invalid number of arguments.'
    fi
    return 0
}

koopa::assert_has_args_ge() { # {{{1
    # """
    # Assert that greater-than-or-equal-to an expected number of arguments have
    # been passed.
    # @note Updated 2020-07-03.
    # """
    if [[ "$#" -ne 2 ]]
    then
        koopa::stop '"koopa::assert_has_args_ge" requires 2 args.'
    fi
    if [[ ! "${1:?}" -ge "${2:?}" ]]
    then
        koopa::stop 'Invalid number of arguments.'
    fi
    return 0
}

koopa::assert_has_args_ge() { # {{{1
    # """
    # Assert that greater-than-or-equal-to an expected number of arguments have
    # been passed.
    # @note Updated 2020-07-03.
    # """
    if [[ "$#" -ne 2 ]]
    then
        koopa::stop '"koopa::assert_has_args_ge" requires 2 args.'
    fi
    if [[ ! "${1:?}" -ge "${2:?}" ]]
    then
        koopa::stop 'Invalid number of arguments.'
    fi
    return 0
}

koopa::assert_has_args_le() { # {{{1
    # """
    # Assert that less-than-or-equal-to an expected number of arguments have
    # been passed.
    # @note Updated 2020-07-03.
    # """
    if [[ "$#" -ne 2 ]]
    then
        koopa::stop '"koopa::assert_has_args_le" requires 2 args.'
    fi
    if [[ ! "${1:?}" -le "${2:?}" ]]
    then
        koopa::stop 'Invalid number of arguments.'
    fi
    return 0
}

koopa::assert_has_file_ext() { # {{{1
    # """
    # Assert that input contains a file extension.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::has_file_ext "$arg"
        then
            koopa::stop "No file extension: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_has_monorepo() { # {{{1
    # """
    # Assert that the user has a git monorepo.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::has_monorepo
    then
        koopa::stop "No monorepo at '$(koopa::monorepo_prefix)'."
    fi
    return 0
}

koopa::assert_has_no_args() { # {{{1
    # """
    # Assert that the user has not passed any arguments to a script.
    # @note Updated 2022-02-15.
    # """
    if [[ "$#" -ne 1 ]]
    then
        koopa::stop \
            '"koopa::assert_has_no_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -ne 0 ]]
    then
        koopa::stop 'Arguments are not allowed.'
    fi
    return 0
}

koopa::assert_has_no_envs() { # {{{1
    # """
    # Assert that conda and Python virtual environments aren't active.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::has_no_environments
    then
        koopa::stop "\
Active environment detected.
       (conda and/or python venv)

Deactivate using:
    venv:  deactivate
    conda: conda deactivate

Deactivate venv prior to conda, otherwise conda python may be left in PATH."
    fi
    return 0
}

koopa::assert_has_no_flags() { # {{{1
    # """
    # Assert that the user input does not contain flags.
    # @note Updated 2021-09-20.
    # """
    while (("$#"))
    do
        case "$1" in
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                shift 1
                ;;
        esac
    done
    return 0
}

koopa::assert_is_aarch64() { # {{{1
    # """
    # Assert that platform is ARM 64-bit.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_aarch64
    then
        koopa::stop 'Architecture is not aarch64 (ARM 64-bit).'
    fi
    return 0
}

koopa::assert_is_admin() { # {{{1
    # """
    # Assert that current user has admin permissions.
    # @note Updated 2021-05-14.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_admin
    then
        koopa::stop 'Administrator account is required.'
    fi
    return 0
}

koopa::assert_is_array_non_empty() { # {{{1
    # """
    # Assert that array is non-empty.
    # @note Updated 2020-03-06.
    # """
    if ! koopa::is_array_non_empty "$@"
    then
        koopa::stop 'Array is empty.'
    fi
    return 0
}

koopa::assert_is_conda_active() { # {{{1
    # """
    # Assert that a Conda environment is active.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_conda_active
    then
        koopa::stop 'No active Conda environment detected.'
    fi
    return 0
}

koopa::assert_is_current_version() { # {{{1
    # """
    # Assert that programs are installed (and current).
    # @note Updated 2020-02-16.
    # """
    local arg expected
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_installed "$arg"
        then
            expected="$(koopa::variable "$arg")"
            koopa::stop "'${arg}' is not current; expecting '${expected}'."
        fi
    done
    return 0
}

koopa::assert_is_dir() { # {{{1
    # """
    # Assert that input is a directory.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -d "$arg" ]]
        then
            koopa::stop "Not directory: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_executable() { # {{{1
    # """
    # Assert that input is executable.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -x "$arg" ]]
        then
            koopa::stop "Not executable: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_existing() { # {{{1
    # """
    # Assert that input exists on disk.
    # @note Updated 2020-02-16.
    #
    # Note that '-e' flag returns true for file, dir, or symlink.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -e "$arg" ]]
        then
            koopa::stop "Does not exist: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_file() { # {{{1
    # """
    # Assert that input is a file.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -f "$arg" ]]
        then
            koopa::stop "Not file: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_file_type() { # {{{1
    # """
    # Assert that input matches a specified file type.
    # @note Updated 2020-01-12.
    #
    # @examples
    # koopa::assert_is_file_type "$x' 'csv"
    # """
    local ext file
    koopa::assert_has_args_eq "$#" 2
    file="${1:?}"
    ext="${2:?}"
    koopa::assert_is_file "$file"
    koopa::assert_is_matching_regex "$file" "\.${ext}\$"
}

koopa::assert_is_function() { # {{{1
    # """
    # Assert that variable is a function.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_function "$arg"
        then
            koopa::stop "Not function: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_git_repo() { # {{{1
    # """
    # Assert that current directory is a git repo.
    # @note Updated 2021-08-19.
    #
    # Intentionally doesn't support input of multiple directories here.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_git_repo
    then
        koopa::stop "Not a Git repo: '${PWD:?}'."
    fi
    return 0
}

koopa::assert_is_github_ssh_enabled() { # {{{1
    # """
    # Assert that current user has SSH key access to GitHub.
    # @note Updated 2020-02-11.
    # """
    if ! koopa::is_github_ssh_enabled
    then
        koopa::stop 'GitHub SSH access is not configured correctly.'
    fi
    return 0
}

koopa::assert_is_gitlab_ssh_enabled() { # {{{1
    # """
    # Assert that current user has SSH key access to GitLab.
    # @note Updated 2020-02-11.
    # """
    if ! koopa::is_gitlab_ssh_enabled
    then
        koopa::stop 'GitLab SSH access is not configured correctly.'
    fi
    return 0
}

koopa::assert_is_gnu() {  #{{{1
    # """
    # Assert that GNU version of a program is installed.
    # @note Updated 2021-05-20.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_gnu "$arg"
        then
            koopa::stop "GNU ${arg} is not installed."
        fi
    done
    return 0
}

koopa::assert_is_installed() { # {{{1
    # """
    # Assert that programs are installed.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_installed "$arg"
        then
            koopa::stop "Not installed: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_koopa_app() { # {{{1
    # """
    # Assert that input is an application installed in koopa app prefix.
    # @note Updated 2021-06-14.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_koopa_app "$arg"
        then
            koopa::stop "Not koopa app: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_linux() { # {{{1
    # """
    # Assert that operating system is Linux.
    # @note Updated 2020-11-13.
    # """
    if ! koopa::is_linux
    then
        koopa::stop 'Linux is required.'
    fi
    return 0
}

koopa::assert_is_macos() { # {{{1
    # """
    # Assert that operating system is macOS.
    # @note Updated 2020-11-13.
    # """
    if ! koopa::is_macos
    then
        koopa::stop 'macOS is required.'
    fi
    return 0
}

koopa::assert_is_matching_fixed() { # {{{1
    # """
    # Assert that input matches a fixed pattern.
    # @note Updated 2020-01-12.
    # """
    local pattern string
    koopa::assert_has_args_eq "$#" 2
    string="${1:?}"
    pattern="${2:?}"
    if ! koopa::str_detect_fixed "$string" "$pattern"
    then
        koopa::stop "'${string}' doesn't match '${pattern}'."
    fi
    return 0
}

koopa::assert_is_matching_regex() { # {{{1
    # """
    # Assert that input matches a regular expression pattern.
    # @note Updated 2020-01-12.
    # """
    local pattern string
    koopa::assert_has_args_eq "$#" 2
    string="${1:?}"
    pattern="${2:?}"
    if ! koopa::str_detect_regex "$string" "$pattern"
    then
        koopa::stop "'${string}' doesn't match regex '${pattern}'."
    fi
    return 0
}

koopa::assert_is_non_existing() { # {{{1
    # """
    # Assert that input does not exist on disk.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -e "$arg" ]]
        then
            koopa::stop "Exists: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_nonzero_file() { # {{{1
    # """
    # Assert that input is a non-zero file.
    # @note Updated 2020-03-06.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -s "$arg" ]]
        then
            koopa::stop "Not non-zero file: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_not_dir() { # {{{1
    # """
    # Assert that input is not a directory.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -d "$arg" ]]
        then
            koopa::stop "Directory exists: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_not_file() { # {{{1
    # """
    # Assert that input is not a file.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -f "$arg" ]]
        then
            koopa::stop "File exists: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_not_installed() { # {{{1
    # """
    # Assert that programs are not installed.
    # @note Updated 2020-02-16.
    # """
    local arg where
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_installed "$arg"
        then
            where="$(koopa::which_realpath "$arg")"
            koopa::stop "'${arg}' is already installed at '${where}'."
        fi
    done
    return 0
}

koopa::assert_is_not_root() { # {{{1
    # """
    # Assert that current user is not root.
    # @note Updated 2019-12-17.
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_root
    then
        koopa::stop 'root user detected.'
    fi
    return 0
}

koopa::assert_is_not_symlink() { # {{{1
    # """
    # Assert that input is not a symbolic link.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -L "$arg" ]]
        then
            koopa::stop "Symlink exists: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_python_package_installed() { # {{{1
    # """
    # Assert that specific Python packages are installed.
    # @note Updated 2020-07-10.
    # """
    koopa::assert_has_args "$#"
    if ! koopa::is_python_package_installed "$@"
    then
        koopa::dl 'Args' "$*"
        koopa::stop 'Required Python packages missing.'
    fi
    return 0
}

koopa::assert_is_python_venv_active() { # {{{1
    # """
    # Assert that a Python virtual environment is active.
    # @note Updated 2021-06-14.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_python_venv_active
    then
        koopa::stop 'No active Python venv detected.'
    fi
    return 0
}

koopa::assert_is_r_package_installed() { # {{{1
    # """
    # Assert that specific R packages are installed.
    # @note Updated 2020-07-10.
    # """
    koopa::assert_has_args "$#"
    if ! koopa::is_r_package_installed "$@"
    then
        koopa::dl 'Args' "$*"
        koopa::stop 'Required R packages missing.'
    fi
    return 0
}

koopa::assert_is_readable() { # {{{1
    # """
    # Assert that input is readable.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -r "$arg" ]]
        then
            koopa::stop "Not readable: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_root() { # {{{1
    # """
    # Assert that the current user is root.
    # @note Updated 2019-12-17.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_root
    then
        koopa::stop 'root user is required.'
    fi
    return 0
}

koopa::assert_is_set() { # {{{1
    # """
    # Assert that variables are set (and not unbound).
    # @note Updated 2021-11-05.
    #
    # @examples
    # declare -A dict=(
    #     [aaa]='AAA'
    #     [bbb]='BBB'
    # )
    # koopa::assert_is_set \
    #     '--aaa' "${dict[aaa]:-}" \
    #     '--bbb' "${dict[bbb]:-}"
    # """
    local name value
    koopa::assert_has_args_ge "$#" 2
    while (("$#"))
    do
        name="${1:?}"
        value="${2:-}"
        shift 2
        if [[ -z "${value}" ]]
        then
            koopa::stop "'${name}' is unset."
        fi
    done
    return 0
}

koopa::assert_is_set_2() { # {{{1
    # """
    # Assert that variables are set (and not unbound).
    # @note Updated 2021-11-05.
    #
    # Intended to use inside of functions, where we can't be sure that 'set -u'
    # mode is set, which otherwise catches unbound variables.
    #
    # How to return bash variable name:
    # - https://unix.stackexchange.com/questions/129084
    #
    # @examples
    # koopa::assert_is_set_2 'PATH' 'MANPATH'
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_set "$arg"
        then
            koopa::stop "'${arg}' is unset."
        fi
    done
    return 0
}

koopa::assert_is_symlink() { # {{{1
    # """
    # Assert that input is a symbolic link.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -L "$arg" ]]
        then
            koopa::stop "Not symlink: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_writable() { # {{{1
    # """
    # Assert that input is writable.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -r "$arg" ]]
        then
            koopa::stop "Not writable: '${arg}'."
        fi
    done
    return 0
}

koopa::assert_is_x86_64() { # {{{1
    # """
    # Assert that platform is Intel x86 64-bit.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_x86_64
    then
        koopa::stop 'Architecture is not x86_64 (Intel x86 64-bit).'
    fi
    return 0
}
