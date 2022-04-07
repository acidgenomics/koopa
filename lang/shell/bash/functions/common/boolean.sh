#!/usr/bin/env bash

__koopa_is_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled (e.g. for git)?
    # @note Updated 2022-02-17.
    #
    # @seealso
    # - https://help.github.com/en/github/authenticating-to-github/
    #       testing-your-ssh-connection
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 2
    declare -A app=(
        [ssh]="$(koopa_locate_ssh)"
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
    koopa_str_detect_fixed \
        --string="${dict[str]}" \
        --pattern="${dict[pattern]}"
}

koopa_contains() { # {{{1
    # """
    # Does an array contain a specific element?
    # @note Updated 2021-05-07.
    #
    # @seealso
    # https://stackoverflow.com/questions/3685970/
    #
    # @examples
    # > string='foo'
    # > array=('foo' 'bar')
    # > koopa_contains "$string" "${array[@]}"
    # """
    local string x
    koopa_assert_has_args_ge "$#" 2
    string="${1:?}"
    shift 1
    for x
    do
        [[ "$x" == "$string" ]] && return 0
    done
    return 1
}

koopa_has_file_ext() { # {{{1
    # """
    # Does the input contain a file extension?
    # @note Updated 2022-02-17.
    #
    # @examples
    # > koopa_has_file_ext 'hello.txt'
    # """
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        koopa_str_detect_fixed \
            --string="$(koopa_print "$file")" \
            --pattern='.' \
        || return 1
    done
    return 0
}

koopa_has_monorepo() { # {{{1
    # """
    # Does the current user have a monorepo?
    # @note Updated 2020-07-03.
    # """
    [[ -d "$(koopa_monorepo_prefix)" ]]
}

koopa_has_no_environments() { # {{{1
    # """
    # Detect activation of virtual environments.
    # @note Updated 2021-06-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_is_conda_active && return 1
    koopa_is_python_venv_active && return 1
    return 0
}

koopa_has_passwordless_sudo() { # {{{1
    # """
    # Check if sudo is active or doesn't require a password.
    # @note Updated 2021-10-27.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_is_root && return 0
    koopa_is_installed 'sudo' || return 1
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" -n true 2>/dev/null && return 0
    return 1
}

koopa_is_admin() { # {{{1
    # """
    # Check that current user has administrator permissions.
    # @note Updated 2022-02-17.
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
    koopa_assert_has_no_args "$#"
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
    koopa_is_root && return 0
    # Return false if 'sudo' program is not installed.
    koopa_is_installed 'sudo' || return 1
    # Early return true if user has passwordless sudo enabled.
    koopa_has_passwordless_sudo && return 0
    # Check if user is any accepted admin group.
    # Note that this step is very slow for Active Directory domain accounts.
    declare -A app=(
        [groups]="$(koopa_locate_groups)"
    )
    groups="$("${app[groups]}")"
    [[ -n "$groups" ]] || return 1
    pattern='\b(admin|root|sudo|wheel)\b'
    koopa_str_detect_regex \
        --string="$groups" \
        --pattern="$pattern" \
        && return 0
    return 1
}

koopa_is_anaconda() { # {{{1
    # """
    # Is Anaconda (rather than Miniconda) installed?
    # @note Updated 2022-02-01.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [conda]="${1:-}"
    )
    [[ -z "${app[conda]}" ]] && app[conda]="$(koopa_locate_conda)"
    [[ -x "${app[conda]}" ]] || return 1
    declare -A dict=(
        [prefix]="$(koopa_parent_dir --num=2 "${app[conda]}")"
    )
    [[ -x "${dict[prefix]}/bin/anaconda" ]] || return 1
    return 0
}

koopa_is_array_empty() { # {{{1
    # """
    # Is the array input empty?
    # @note Updated 2020-12-03.
    # """
    ! koopa_is_array_non_empty "$@"
}

koopa_is_array_non_empty() { # {{{1
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

koopa_is_current_version() { # {{{1
    # """
    # Is the program version current?
    # @note Updated 2020-07-20.
    # """
    local actual_version app expected_version
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        expected_version="$(koopa_variable "$app")"
        actual_version="$(koopa_get_version "$app")"
        [[ "$actual_version" == "$expected_version" ]] || return 1
    done
    return 0
}

koopa_is_defined_in_user_profile() { # {{{1
    # """
    # Is koopa defined in current user's shell profile configuration file?
    # @note Updated 2022-02-17.
    # """
    local file
    koopa_assert_has_no_args "$#"
    file="$(koopa_find_user_profile)"
    koopa_file_detect_fixed --file="$file" --pattern='koopa'
}

koopa_is_doom_emacs_installed() { # {{{1
    # """
    # Is Doom Emacs installed?
    # @note Updated 2021-10-25.
    # """
    local init_file prefix
    koopa_assert_has_no_args "$#"
    koopa_is_installed 'emacs' || return 1
    prefix="$(koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    koopa_file_detect_fixed --file="$init_file" --pattern='doom-emacs'
}

koopa_is_empty_dir() { # {{{1
    # """
    # Is the input an empty directory?
    # @note Updated 2022-02-24.
    #
    # @examples
    # > koopa_mkdir 'aaa' 'bbb'
    # > koopa_is_empty_dir 'aaa' 'bbb'
    # > koopa_rm 'aaa' 'bbb'
    # """
    local prefix
    koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        local out
        [[ -d "$prefix" ]] || return 1
        out="$(\
            koopa_find \
            --empty \
            --engine='find' \
            --max-depth=0 \
            --min-depth=0 \
            --prefix="$prefix" \
            --type='d'
        )"
        [[ -n "$out" ]] || return 1
    done
    return 0
}

koopa_is_export() { # {{{1
    # """
    # Is a variable exported in the current shell session?
    # @note Updated 2022-02-17.
    #
    # Use 'export -p' (POSIX) instead of 'declare -x' (Bashism).
    #
    # See also:
    # - https://unix.stackexchange.com/questions/390831
    #
    # @examples
    # > koopa_is_export 'KOOPA_SHELL'
    # """
    local arg exports
    koopa_assert_has_args "$#"
    exports="$(export -p)"
    for arg in "$@"
    do
        koopa_str_detect_regex \
            --string="$exports" \
            --pattern="\b${arg}\b=" \
        || return 1
    done
    return 0
}

koopa_is_file_system_case_sensitive() { # {{{1
    # """
    # Is the file system case sensitive?
    # @note Updated 2022-02-24.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [find]="$(koopa_locate_find)"
        [wc]="$(koopa_locate_wc)"
    )
    declare -A dict=(
        [prefix]="${PWD:?}"
        [tmp_stem]='.koopa.tmp.'
    )
    dict[file1]="${dict[tmp_stem]}checkcase"
    dict[file2]="${dict[tmp_stem]}checkCase"
    koopa_touch "${dict[file1]}" "${dict[file2]}"
    dict[count]="$( \
        "${app[find]}" \
            "${dict[prefix]}" \
            -maxdepth 1 \
            -mindepth 1 \
            -name "${dict[file1]}" \
        | "${app[wc]}" --lines \
    )"
    koopa_rm "${dict[tmp_stem]}"*
    [[ "${dict[count]}" -eq 2 ]]
}

koopa_is_file_type() { # {{{1
    # """
    # Does the input exist and match a file type extension?
    # @note Updated 2022-02-17.
    #
    # @usage koopa_is_file_type --ext=EXT FILE...
    #
    # @examples
    # > koopa_is_file_type --ext='csv' 'aaa.csv' 'bbb.csv'
    # """
    local dict file pos
    declare -A dict=(
        [ext]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--ext='*)
                dict[ext]="${1#*=}"
                shift 1
                ;;
            '--ext')
                dict[ext]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--ext' "${dict[ext]}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        [[ -f "$file" ]] || return 1
        koopa_str_detect_regex \
            --string="$file" \
            --pattern="\.${dict[ext]}$" \
        || return 1
    done
    return 0
}

koopa_is_function() { # {{{1
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
    koopa_assert_has_args "$#"
    for fun in "$@"
    do
        [[ "$(type -t "$fun")" == 'function' ]] || return 1
    done
    return 0
}

koopa_is_github_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitHub access?
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_no_args "$#"
    __koopa_is_ssh_enabled 'git@github.com' 'successfully authenticated'
}

koopa_is_gitlab_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitLab access?
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_no_args "$#"
    __koopa_is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}

koopa_is_gnu() { # {{{1
    # """
    # Is a GNU program installed?
    # @note Updated 2022-01-21.
    # """
    local cmd str
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        koopa_is_installed "$cmd" || return 1
        str="$("$cmd" --version 2>&1 || true)"
        koopa_str_detect_posix "$str" 'GNU' || return 1
    done
    return 0
}

koopa_is_koopa_app() { # {{{1
    # """
    # Is a specific command installed in koopa app prefix?
    # @note Updated 2022-02-17.
    # """
    local app_prefix str
    koopa_assert_has_args "$#"
    app_prefix="$(koopa_app_prefix)"
    [[ -d "$app_prefix" ]] || return 1
    for str in "$@"
    do
        if koopa_is_installed "$str"
        then
            str="$(koopa_which_realpath "$str")"
        elif [[ -e "$str" ]]
        then
            str="$(koopa_realpath "$str")"
        else
            return 1
        fi
        koopa_str_detect_regex \
            --string="$str" \
            --pattern="^${app_prefix}" \
            || return 1
    done
    return 0
}

koopa_is_powerful_machine() { # {{{1
    # """
    # Is the current machine powerful?
    # @note Updated 2021-11-05.
    # """
    local cores
    koopa_assert_has_no_args "$#"
    cores="$(koopa_cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}

koopa_is_python_package_installed() { # {{{1
    # """
    # Check if Python package is installed.
    # @note Updated 2022-02-03.
    #
    # Fast mode: checking the 'site-packages' directory.
    #
    # Alternate, slow mode:
    # > local freeze
    # > freeze="$("$python" -m pip freeze)"
    # > koopa_str_detect_regex --string="$freeze" --pattern="^${pkg}=="
    #
    # See also:
    # - https://stackoverflow.com/questions/1051254
    # - https://askubuntu.com/questions/588390

    # @examples
    # > koopa_is_python_package_installed 'black' 'pytest'
    # """
    local app dict pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    declare -A dict
    dict[version]="$(koopa_get_version "${app[python]}")"
    dict[prefix]="$(koopa_python_packages_prefix "${dict[version]}")"
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

koopa_is_r_package_installed() { # {{{1
    # """
    # Is the requested R package installed?
    # @note Updated 2022-02-03.
    #
    # @examples
    # > koopa_is_r_package_installed 'BiocGenerics' 'S4Vectors'
    # """
    local app dict pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    declare -A dict
    dict[version]="$(koopa_get_version "${app[r]}")"
    dict[prefix]="$(koopa_r_packages_prefix "${dict[version]}")"
    for pkg in "$@"
    do
        [[ -d "${dict[prefix]}/${pkg}" ]] || return 1
    done
    return 0
}

koopa_is_recent() { # {{{1
    # """
    # If the file exists and is more recent than 2 weeks old.
    # @note Updated 2022-02-24.
    #
    # Current approach uses find to filter based on modification date.
    #
    # Alternatively, can we use 'stat' to compare the modification time to Unix
    # epoch in seconds or with GNU date.
    #
    # NB Don't attempt to use 'koopa_find' here, as this is acting directly
    # on a file rather than directory input.
    #
    # @seealso
    # - https://stackoverflow.com/a/32019461
    # - fd using '--changed-before <DAYS>d' argument.
    #
    # @examples
    # > koopa_is_recent ~/hello-world.txt
    # """
    local app dict file
    koopa_assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa_locate_find)"
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

koopa_is_spacemacs_installed() { # {{{1
    # """
    # Is Spacemacs installed?
    # @note Updated 2022-02-17.
    # """
    local init_file prefix
    koopa_assert_has_no_args "$#"
    koopa_is_installed 'emacs' || return 1
    prefix="$(koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    koopa_file_detect_fixed --file="$init_file" --pattern='Spacemacs'
}

koopa_is_url_active() { # {{{1
    # """
    # Check if input is a URL and is active.
    # @note Updated 2022-04-07.
    #
    # @section cURL approach:
    #
    # Can also use "--range '0-0'" instead of '--head' here.
    #
    # @section wget approach:
    #
    # > "${app[wget]}" --spider "$url" 2>/dev/null || return 1
    #
    # @seealso
    # - https://stackoverflow.com/questions/12199059/
    #
    # @examples
    # # TRUE:
    # > koopa_is_url_active 'https://google.com/'
    #
    # # FALSE:
    # > koopa_is_url_active 'https://google.com/asdf'
    # """
    local app url
    koopa_assert_has_args "$#"
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
    )
    declare -A dict=(
        [url_pattern]='://'
    )
    for url in "$@"
    do
        koopa_str_detect_fixed \
            --pattern="${dict[url_pattern]}" \
            --string="$url" \
            || return 1
        "${app[curl]}" \
            --disable \
            --fail \
            --head \
            --location \
            --output /dev/null \
            --silent \
            "$url" \
            || return 1
        continue
    done
    return 0
}

koopa_is_variable_defined() { # {{{1
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
    # > koopa_is_variable_defined 'PATH'
    # """
    local dict var
    koopa_assert_has_args "$#"
    declare -A dict=(
        [nounset]="$(koopa_boolean_nounset)"
    )
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
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
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_is_xcode_clt_installed() { # {{{1
    # """
    # Is Xcode CLT (command line tools) installed?
    # @note Updated 2021-10-26.
    # """
    koopa_assert_has_no_args "$#"
    koopa_is_macos || return 1
    [[ -d '/Library/Developer/CommandLineTools/usr/bin' ]] || return 1
    return 0
}
