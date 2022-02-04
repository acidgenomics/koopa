#!/usr/bin/env bash

koopa:::is_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled (e.g. for git)?
    # @note Updated 2022-02-01.
    #
    # @seealso
    # - https://help.github.com/en/github/authenticating-to-github/
    #       testing-your-ssh-connection
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 2
    declare -A app=(
        [ssh]="$(koopa::locate_ssh)"
    )
    declare -A dict=(
        [url]="${1:?}"
        [pattern]="${2:?}"
    )
    dict[str]="$( \
        "${app[ssh]}" -T \
            -o StrictHostKeyChecking='no' \
            "${dict[url]}" 2>&1 \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::str_detect_fixed "${dict[str]}" "${dict[pattern]}"
}

koopa::contains() { # {{{1
    # """
    # Does an array contain a specific element?
    # @note Updated 2021-05-07.
    #
    # @examples
    # string='foo'
    # array=('foo' 'bar')
    # koopa::contains "$string" "${array[@]}"
    #
    # @seealso
    # https://stackoverflow.com/questions/3685970/
    # """
    local string x
    koopa::assert_has_args_ge "$#" 2
    string="${1:?}"
    shift 1
    for x
    do
        [[ "$x" == "$string" ]] && return 0
    done
    return 1
}

koopa::has_file_ext() { # {{{1
    # """
    # Does the input contain a file extension?
    # @note Updated 2020-07-04.
    #
    # @examples
    # koopa::has_file_ext 'hello.txt'
    # """
    local file
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        koopa::str_detect_fixed "$(koopa::print "$file")" '.' || return 1
    done
    return 0
}

koopa::has_monorepo() { # {{{1
    # """
    # Does the current user have a monorepo?
    # @note Updated 2020-07-03.
    # """
    [[ -d "$(koopa::monorepo_prefix)" ]]
}

koopa::has_no_environments() { # {{{1
    # """
    # Detect activation of virtual environments.
    # @note Updated 2021-06-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_conda_active && return 1
    koopa::is_python_venv_active && return 1
    return 0
}

koopa::has_passwordless_sudo() { # {{{1
    # """
    # Check if sudo is active or doesn't require a password.
    # @note Updated 2021-10-27.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::is_root && return 0
    koopa::is_installed 'sudo' || return 1
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" -n true 2>/dev/null && return 0
    return 1
}

koopa::is_admin() { # {{{1
    # """
    # Check that current user has administrator permissions.
    # @note Updated 2021-10-27.
    #
    # This check can hang on some systems with domain user accounts.
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
    # > getent group 'sudo'
    #
    # - macOS: admin
    # - Debian: sudo
    # - Fedora: wheel
    #
    # See also:
    # - https://serverfault.com/questions/364334
    # - https://linuxhandbook.com/check-if-user-has-sudo-rights/
    # """
    local app groups pattern
    koopa::assert_has_no_args "$#"
    if [[ -n "${KOOPA_ADMIN:-}" ]]
    then
        case "${KOOPA_ADMIN:?}" in
            '0')
                return 1
                ;;
            '1')
                return 0
                ;;
        esac
    fi
    # Always return true for root user.
    koopa::is_root && return 0
    # Return false if 'sudo' program is not installed.
    koopa::is_installed 'sudo' || return 1
    # Early return true if user has passwordless sudo enabled.
    koopa::has_passwordless_sudo && return 0
    # Check if user is any accepted admin group.
    # Note that this step is very slow for Active Directory domain accounts.
    declare -A app=(
        [groups]="$(koopa::locate_groups)"
    )
    groups="$("${app[groups]}")"
    [[ -n "$groups" ]] || return 1
    pattern='\b(admin|root|sudo|wheel)\b'
    koopa::str_detect_regex "$groups" "$pattern" && return 0
    return 1
}

koopa::is_anaconda() { # {{{1
    # """
    # Is Anaconda (rather than Miniconda) installed?
    # @note Updated 2022-02-01.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [conda]="${1:-}"
    )
    [[ -z "${app[conda]}" ]] && app[conda]="$(koopa::locate_conda)"
    [[ -x "${app[conda]}" ]] || return 1
    declare -A dict=(
        [prefix]="$(koopa::parent_dir --num=2 "${app[conda]}")"
    )
    [[ -x "${dict[prefix]}/bin/anaconda" ]] || return 1
    return 0
}

koopa::is_array_empty() { # {{{1
    # """
    # Is the array input empty?
    # @note Updated 2020-12-03.
    # """
    ! koopa::is_array_non_empty "$@"
}

koopa::is_array_non_empty() { # {{{1
    # """
    # Is the array non-empty?
    # @note Updated 2021-08-31.
    #
    # Particularly useful for checking against readarray return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    #
    # @seealso
    # - https://serverfault.com/questions/477503/
    # """
    local arr
    [[ "$#" -gt 0 ]] || return 1
    arr=("$@")
    [[ "${#arr[@]}" -gt 0 ]] || return 1
    [[ -n "${arr[0]}" ]] || return 1
    return 0
}

koopa::is_current_version() { # {{{1
    # """
    # Is the program version current?
    # @note Updated 2020-07-20.
    # """
    local actual_version app expected_version
    koopa::assert_has_args "$#"
    for app in "$@"
    do
        expected_version="$(koopa::variable "$app")"
        actual_version="$(koopa::get_version "$app")"
        [[ "$actual_version" == "$expected_version" ]] || return 1
    done
    return 0
}

koopa::is_defined_in_user_profile() { # {{{1
    # """
    # Is koopa defined in current user's shell profile configuration file?
    # @note Updated 2021-10-25.
    # """
    local file
    koopa::assert_has_no_args "$#"
    file="$(koopa::find_user_profile)"
    koopa::file_detect_fixed "$file" 'koopa'
}

koopa::is_doom_emacs_installed() { # {{{1
    # """
    # Is Doom Emacs installed?
    # @note Updated 2021-10-25.
    # """
    local init_file prefix
    koopa::assert_has_no_args "$#"
    koopa::is_installed 'emacs' || return 1
    prefix="$(koopa::emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    koopa::file_detect_fixed "$init_file" 'doom-emacs'
}

koopa::is_empty_dir() { # {{{1
    # """
    # Is the input an empty directory?
    # @note Updated 2021-12-07.
    #
    # @examples
    # koopa::mkdir 'aaa' 'bbb'
    # koopa::is_empty_dir 'aaa' 'bbb'
    # koopa::rm 'aaa' 'bbb'
    # """
    local app out prefix
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
    )
    for prefix in "$@"
    do
        [[ -d "$prefix" ]] || return 1
        prefix="$(koopa::realpath "$prefix")"
        out="$("${app[find]}" "$prefix" \
            -maxdepth 0 \
            -mindepth 0 \
            -type 'd' \
            -empty \
            2>/dev/null \
        )"
        [[ -n "$out" ]] || return 1
    done
    return 0
}

koopa::is_export() { # {{{1
    # """
    # Is a variable exported in the current shell session?
    # @note Updated 2020-06-30.
    #
    # Use 'export -p' (POSIX) instead of 'declare -x' (Bashism).
    #
    # See also:
    # - https://unix.stackexchange.com/questions/390831
    #
    # @examples
    # koopa::is_export 'KOOPA_SHELL'
    # """
    local arg exports
    koopa::assert_has_args "$#"
    exports="$(export -p)"
    for arg in "$@"
    do
        koopa::str_detect_regex "$exports" "\b${arg}\b=" || return 1
    done
    return 0
}

koopa::is_file_system_case_sensitive() { # {{{1
    # """
    # Is the file system case sensitive?
    # @note Updated 2022-01-31.
    #
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [wc]="$(koopa::locate_wc)"
    )
    declare -A dict=(
        [prefix]="${PWD:?}"
        [tmp_stem]='.koopa.tmp.'
    )
    dict[file1]="${dict[tmp_stem]}checkcase"
    dict[file2]="${dict[tmp_stem]}checkCase"
    koopa::touch "${dict[file1]}" "${dict[file2]}"
    dict[count]="$( \
        koopa::find \
            --glob="${dict[file1]}" \
            --ignore-case \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[prefix]}" \
        | "${app[wc]}" -l \
    )"
    koopa::rm "${dict[tmp_stem]}"*
    [[ "${dict[count]}" -eq 2 ]]
}

koopa::is_function() { # {{{1
    # """
    # Check if variable is a function.
    # @note Updated 2021-05-11.
    #
    # Note that 'declare' and 'typeset' are bashisms, and not POSIX.
    # Checking against 'type' works consistently across POSIX shells.
    #
    # Works in bash, ksh, zsh:
    # > typeset -f "$fun"
    #
    # Works in bash, zsh:
    # > declare -f "$fun"
    #
    # Works in bash (note use of '-t' flag):
    # [[ "$(type -t "$fun")" == 'function' ]]
    #
    # @seealso
    # - https://stackoverflow.com/questions/11478673/
    # - https://stackoverflow.com/questions/85880/
    # """
    local fun
    koopa::assert_has_args "$#"
    for fun in "$@"
    do
        [[ "$(type -t "$fun")" == 'function' ]] || return 1
    done
    return 0
}

koopa::is_github_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitHub access?
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::is_ssh_enabled 'git@github.com' 'successfully authenticated'
}

koopa::is_gitlab_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitLab access?
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}

koopa::is_gnu() { # {{{1
    # """
    # Is a GNU program installed?
    # @note Updated 2022-01-21.
    # """
    local cmd str
    koopa::assert_has_args "$#"
    for cmd in "$@"
    do
        koopa::is_installed "$cmd" || return 1
        str="$("$cmd" --version 2>&1 || true)"
        koopa::str_detect_posix "$str" 'GNU' || return 1
    done
    return 0
}

koopa::is_koopa_app() { # {{{1
    # """
    # Is a specific command installed in koopa app prefix?
    # @note Updated 2021-06-14.
    # """
    local app_prefix str
    koopa::assert_has_args "$#"
    app_prefix="$(koopa::app_prefix)"
    [[ -d "$app_prefix" ]] || return 1
    for str in "$@"
    do
        if koopa::is_installed "$str"
        then
            str="$(koopa::which_realpath "$str")"
        elif [[ -e "$str" ]]
        then
            str="$(koopa::realpath "$str")"
        else
            return 1
        fi
        koopa::str_detect_regex "$str" "^${app_prefix}" || return 1
    done
    return 0
}

koopa::is_powerful_machine() { # {{{1
    # """
    # Is the current machine powerful?
    # @note Updated 2021-11-05.
    # """
    local cores
    koopa::assert_has_no_args "$#"
    cores="$(koopa::cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}

koopa::is_python_package_installed() { # {{{1
    # """
    # Check if Python package is installed.
    # @note Updated 2022-02-03.
    #
    # Fast mode: checking the 'site-packages' directory.
    #
    # Alternate, slow mode:
    # > local freeze
    # > freeze="$("$python" -m pip freeze)"
    # > koopa::str_detect_regex "$freeze" "^${pkg}=="
    #
    # See also:
    # - https://stackoverflow.com/questions/1051254
    # - https://askubuntu.com/questions/588390

    # @examples
    # koopa::is_python_package_installed 'black' 'pytest'
    # """
    local app dict pkg
    koopa::assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa::locate_python)"
    )
    declare -A dict
    dict[version]="$(koopa::get_version "${app[python]}")"
    dict[prefix]="$(koopa::python_packages_prefix "${dict[version]}")"
    [[ -d "${dict[prefix]}" ]] || return 1
    for pkg in "$@"
    do
        if [[ ! -d "${dict[prefix]}/${pkg}" ]] && \
            [[ ! -f "${dict[prefix]}/${pkg}.py" ]]
        then
            return 1
        fi
    done

    return 0
}

koopa::is_r_package_installed() { # {{{1
    # """
    # Is the requested R package installed?
    # @note Updated 2022-02-03.
    #
    # @examples
    # koopa::is_r_package_installed 'BiocGenerics' 'S4Vectors'
    # """
    local app dict pkg
    koopa::assert_has_args "$#"
    declare -A app=(
        [r]="$(koopa::locate_r)"
    )
    declare -A dict
    dict[version]="$(koopa::get_version "${app[r]}")"
    dict[prefix]="$(koopa::r_packages_prefix "${dict[version]}")"
    for pkg in "$@"
    do
        [[ -d "${dict[prefix]}/${pkg}" ]] || return 1
    done
    return 0
}

# FIXME Rework using app/dict approach.
koopa::is_recent() { # {{{1
    # """
    # If the file exists and is more recent than 2 weeks old.
    # @note Updated 2022-02-04.
    #
    # Current approach uses GNU find to filter based on modification date.
    #
    # Alternatively, can we use 'stat' to compare the modification time to Unix
    # epoch in seconds or with GNU date.
    #
    # @seealso
    # - https://stackoverflow.com/a/32019461
    # - fd using '--changed-before <DAYS>d' argument.
    #
    # @examples
    # koopa::is_recent ~/hello-world.txt
    # """
    local app dict file
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
    )
    declare -A dict=(
        [days]=14
    )
    for file in "$@"
    do
        local exists
        [[ -e "$file" ]] || return 1
        exists="$( \
            "${app[find]}" "$file" \
                -mindepth 0 \
                -maxdepth 0 \
                -mtime "-${dict[days]}" \
            2>/dev/null \
        )"
        [[ -n "$exists" ]] || return 1
    done
    return 0
}

koopa::is_spacemacs_installed() { # {{{1
    # """
    # Is Spacemacs installed?
    # @note Updated 2021-10-25.
    # """
    local init_file prefix
    koopa::assert_has_no_args "$#"
    koopa::is_installed 'emacs' || return 1
    prefix="$(koopa::emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    koopa::file_detect_fixed "$init_file" 'Spacemacs'
}

koopa::is_variable_defined() { # {{{1
    # """
    # Is the variable defined (and non-empty)?
    # @note Updated 2022-02-04.
    #
    # Passthrough of empty strings is bad practice in shell scripting.
    #
    # Note that usage of 'declare' here is a bashism.
    # Can consider using 'type' instead for POSIX compliance.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3601515
    # - https://unix.stackexchange.com/questions/504082
    # - https://www.gnu.org/software/bash/manual/html_node/
    #       Shell-Parameter-Expansion.html
    #
    # @examples
    # koopa::is_variable_defined 'PATH'
    # """
    local nounset var
    koopa::assert_has_args "$#"
    nounset="$(koopa::boolean_nounset)"
    [[ "${nounset:-0}" -eq 1 ]] && set +u
    for var
    do
        local x value
        # Check if variable is defined.
        x="$(declare -p "$var" 2>/dev/null || true)"
        [[ -n "${x:-}" ]] || return 1
        # Check if variable contains non-empty value.
        value="${!var}"
        [[ -n "${value:-}" ]] || return 1
    done
    [[ "${nounset:-0}" -eq 1 ]] && set -u
    return 0
}

koopa::is_xcode_clt_installed() { # {{{1
    # """
    # Is Xcode CLT (command line tools) installed?
    # @note Updated 2021-10-26.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_macos || return 1
    [[ -d '/Library/Developer/CommandLineTools/usr/bin' ]] || return 1
    return 0
}
