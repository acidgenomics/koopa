#!/usr/bin/env bash

koopa_exec_dir() { # {{{1
    # """
    # Execute multiple shell scripts in a directory.
    # @note Updated 2022-01-20.
    # """
    local file prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        koopa_assert_is_dir "$prefix"
        for file in "${prefix}/"*'.sh'
        do
            [ -x "$file" ] || continue
            # shellcheck source=/dev/null
            "$file"
        done
    done
    return 0
}

koopa_header() { # {{{1
    # """
    # Shared language-specific header file.
    # @note Updated 2022-02-15.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [lang]="$(koopa_lowercase "${1:?}")"
        [prefix]="$(koopa_koopa_prefix)/lang"
    )
    case "${dict[lang]}" in
        'bash' | \
        'posix' | \
        'zsh')
            dict[prefix]="${dict[prefix]}/shell"
            dict[ext]='sh'
            ;;
        'r')
            dict[ext]='R'
            ;;
        *)
            koopa_invalid_arg "${dict[lang]}"
            ;;
    esac
    dict[file]="${dict[prefix]}/${dict[lang]}/include/header.${dict[ext]}"
    koopa_assert_is_file "${dict[file]}"
    koopa_print "${dict[file]}"
    return 0
}

koopa_help() { # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2022-02-24.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [man]="$(koopa_locate_man)"
    )
    declare -A dict=(
        [man_file]="${1:?}"
    )
    koopa_assert_is_file "${dict[man_file]}"
    "${app[head]}" -n 10 "${dict[man_file]}" \
        | koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app[man]}" "${dict[man_file]}"
    exit 0
}

koopa_help_2() { # {{{1
    # """
    # Resolve man file for current script, and call help.
    # @note Updated 2022-02-25.
    #
    # Currently used inside shared Bash header.
    # """
    local dict
    declare -A dict
    dict[script_file]="$(koopa_realpath "$0")"
    dict[script_name]="$(koopa_basename "${dict[script_file]}")"
    dict[man_prefix]="$( \
        koopa_parent_dir --num=2 "${dict[script_file]}" \
    )"
    dict[man_file]="${dict[man_prefix]}/man/\
man1/${dict[script_name]}.1"
    koopa_help "${dict[man_file]}"
}

koopa_info_box() { # {{{1
    # """
    # Configuration information box.
    # @note Updated 2021-03-30.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    # """
    koopa_assert_has_args "$#"
    local array
    array=("$@")
    local barpad
    barpad="$(printf '━%.0s' {1..70})"
    printf '  %s%s%s  \n' '┏' "$barpad" '┓'
    for i in "${array[@]}"
    do
        printf '  ┃ %-68s ┃  \n' "${i::68}"
    done
    printf '  %s%s%s  \n\n' '┗' "$barpad" '┛'
    return 0
}

koopa_mktemp() { # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2022-02-16.
    #
    # Traditionally, many shell scripts take the name of the program with the
    # pid as a suffix and use that as a temporary file name. This kind of
    # naming scheme is predictable and the race condition it creates is easy for
    # an attacker to win. A safer, though still inferior, approach is to make a
    # temporary directory using the same naming scheme. While this does allow
    # one to guarantee that a temporary file will not be subverted, it still
    # allows a simple denial of service attack. For these reasons it is
    # suggested that mktemp be used instead.
    #
    # Note that old version of mktemp (e.g. macOS) only supports '-t' instead of
    # '--tmpdir' flag for prefix.
    #
    # @seealso
    # - https://st xackoverflow.com/questions/4632028
    # - https://stackoverflow.com/a/10983009/3911732
    # - https://gist.github.com/earthgecko/3089509
    # """
    local app dict mktemp_args str
    declare -A app=(
        [mktemp]="$(koopa_locate_mktemp)"
    )
    declare -A dict=(
        [date_id]="$(koopa_datetime)"
        [user_id]="$(koopa_user_id)"
    )
    dict[template]="koopa-${dict[user_id]}-${dict[date_id]}-XXXXXXXXXX"
    mktemp_args=(
        "$@"
        '-t' "${dict[template]}"
    )
    str="$("${app[mktemp]}" "${mktemp_args[@]}")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_pager() { # {{{1
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2022-02-15.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local app args
    koopa_assert_has_args "$#"
    declare -A app=(
        [less]="$(koopa_locate_less)"
    )
    args=("$@")
    koopa_assert_is_file "${args[-1]}"
    "${app[less]}" -R "${args[@]}"
    return 0
}

koopa_roff() { # {{{1
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2022-02-17.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [ronn]="$(koopa_locate_ronn)"
    )
    declare -A app=(
        [man_prefix]="$(koopa_man_prefix)"
    )
    (
        koopa_cd "${dict[man_prefix]}"
        "${app[ronn]}" --roff ./*'.ronn'
        koopa_mv --target-directory='man1' ./*'.1'
    )
    return 0
}

koopa_run_if_installed() { # {{{1
    # """
    # Run program(s) if installed.
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        local exe
        if ! koopa_is_installed "$arg"
        then
            koopa_alert_note "Skipping '${arg}'."
            continue
        fi
        exe="$(koopa_which_realpath "$arg")"
        "$exe"
    done
    return 0
}

koopa_source_dir() { # {{{1
    # """
    # Source multiple shell scripts in a directory.
    # @note Updated 2022-02-17.
    # """
    local file prefix
    koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    koopa_assert_is_dir "$prefix"
    for file in "${prefix}/"*'.sh'
    do
        [[ -f "$file" ]] || continue
        # shellcheck source=/dev/null
        . "$file"
    done
    return 0
}

koopa_switch_to_develop() {  # {{{1
    # """
    # Switch koopa install to development version.
    # @note Updated 2022-02-14.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    declare -A dict=(
        [branch]='develop'
        [origin]='origin'
        [prefix]="$(koopa_koopa_prefix)"
    )
    koopa_alert "Switching koopa at '${dict[prefix]}' to '${dict[branch]}'."
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    (
        koopa_cd "${dict[prefix]}"
        "${app[git]}" checkout \
            -B "${dict[branch]}" \
            "${dict[origin]}/${dict[branch]}"
    )
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_fix_zsh_permissions
    return 0
}

koopa_sys_group() { # {{{1
    # """
    # Return the appropriate group to use with koopa installation.
    # @note Updated 2020-07-04.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    # """
    local group
    koopa_assert_has_no_args "$#"
    if koopa_is_shared_install
    then
        group="$(koopa_admin_group)"
    else
        group="$(koopa_group)"
    fi
    koopa_print "$group"
    return 0
}

koopa_sys_ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2022-04-07.
    #
    # Don't need to set 'g+rw' for symbolic link here.
    # Symlink permissions are ignored on most systems, including Linux.
    #
    # On macOS, you can override using BSD ln:
    # > /bin/ln -h g+rw <file>
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [source]="${1:?}"
        [target]="${2:?}"
    )
    koopa_ln "${dict[source]}" "${dict[target]}"
    koopa_sys_set_permissions --no-dereference "${dict[target]}"
    return 0
}

koopa_sys_mkdir() { # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2022-04-07.
    # """
    koopa_assert_has_args "$#"
    koopa_mkdir "$@"
    koopa_sys_set_permissions "$@"
    return 0
}

koopa_sys_set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2022-04-07.
    #
    # Consider ensuring that nested directories are also executable.
    # e.g. 'app/julia-packages/1.6/registries/General'.
    # """
    koopa_assert_has_args "$#"
    local arg chmod_args chown_args dict pos
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [shared]=1
    )
    chmod_args=()
    chown_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                dict[dereference]=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict[dereference]=0
                shift 1
                ;;
            '--recursive' | \
            '-R' | \
            '-r')
                dict[recursive]=1
                shift 1
                ;;
            '--user' | \
            '-u')
                dict[shared]=0
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    case "${dict[shared]}" in
        '0')
            dict[group]="$(koopa_group)"
            dict[user]="$(koopa_user)"
            ;;
        '1')
            dict[group]="$(koopa_sys_group)"
            dict[user]="$(koopa_sys_user)"
            ;;
    esac
    chown_args+=('--no-dereference')
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod_args+=('--recursive')
        chown_args+=('--recursive')
    fi
    if koopa_is_shared_install
    then
        chmod_args+=('u+rw,g+rw,o+r,o-w')
    else
        chmod_args+=('u+rw,g+r,g-w,o+r,o-w')
    fi
    chown_args+=("${dict[user]}:${dict[group]}")
    for arg in "$@"
    do
        if [[ "${dict[dereference]}" -eq 1 ]] && [[ -L "$arg" ]]
        then
            arg="$(koopa_realpath "$arg")"
        fi
        chmod_args+=("$arg")
        chown_args+=("$arg")
        koopa_chmod "${chmod_args[@]}"
        koopa_chown "${chown_args[@]}"
    done
    return 0
}

koopa_sys_user() { # {{{1
    # """
    # Set the koopa installation system user.
    # @note Updated 2022-04-05.
    #
    # Previously this set user as 'root' for shared installs, until 2022-04-05.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_user)"
    return 0
}

koopa_system_info() { # {{{
    # """
    # System information.
    # @note Updated 2022-01-25.
    # """
    local app dict info nf_info
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
        [cat]="$(koopa_locate_cat)"
    )
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [arch]="$(koopa_arch)"
        [arch2]="$(koopa_arch2)"
        [ascii_turtle_file]="$(koopa_include_prefix)/ascii-turtle.txt"
        [bash_version]="$(koopa_get_version "${app[bash]}")"
        [config_prefix]="$(koopa_config_prefix)"
        [koopa_date]="$(koopa_koopa_date)"
        [koopa_github_url]="$(koopa_koopa_github_url)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [koopa_url]="$(koopa_koopa_url)"
        [koopa_version]="$(koopa_koopa_version)"
        [make_prefix]="$(koopa_make_prefix)"
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    info=(
        "koopa ${dict[koopa_version]} (${dict[koopa_date]})"
        "URL: ${dict[koopa_url]}"
        "GitHub URL: ${dict[koopa_github_url]}"
    )
    if koopa_is_git_repo_top_level "${dict[koopa_prefix]}"
    then
        dict[remote]="$(koopa_git_remote_url "${dict[koopa_prefix]}")"
        dict[commit]="$(koopa_git_last_commit_local "${dict[koopa_prefix]}")"
        info+=(
            "Git Remote: ${dict[remote]}"
            "Git Commit: ${dict[commit]}"
        )
    fi
    info+=(
        ''
        'Configuration'
        '-------------'
        "Koopa Prefix: ${dict[koopa_prefix]}"
        "App Prefix: ${dict[app_prefix]}"
        "Opt Prefix: ${dict[opt_prefix]}"
        "Config Prefix: ${dict[config_prefix]}"
        "Make Prefix: ${dict[make_prefix]}"
    )
    if koopa_is_macos
    then
        app[sw_vers]="$(koopa_macos_locate_sw_vers)"
        dict[os]="$( \
            printf '%s %s (%s)\n' \
                "$("${app[sw_vers]}" -productName)" \
                "$("${app[sw_vers]}" -productVersion)" \
                "$("${app[sw_vers]}" -buildVersion)" \
        )"
    else
        app[uname]="$(koopa_locate_uname)"
        dict[os]="$("${app[uname]}" --all)"
        # Alternate approach using Python:
        # > app[python]="$(koopa_locate_python)"
        # > dict[os]="$("${app[python]}" -mplatform)"
    fi
    info+=(
        ''
        'System information'
        '------------------'
        "OS: ${dict[os]}"
        "Architecture: ${dict[arch]} / ${dict[arch2]}"
        "Bash: ${dict[bash_version]}"
    )
    if koopa_is_installed 'neofetch'
    then
        app[neofetch]="$(koopa_locate_neofetch)"
        readarray -t nf_info <<< "$("${app[neofetch]}" --stdout)"
        info+=(
            ''
            'Neofetch'
            '--------'
            "${nf_info[@]:2}"
        )
    fi
    "${app[cat]}" "${dict[ascii_turtle_file]}"
    koopa_info_box "${info[@]}"
    return 0
}

koopa_tmp_dir() { # {{{1
    # """
    # Create temporary directory.
    # @note Updated 2020-05-06.
    # """
    local x
    koopa_assert_has_no_args "$#"
    x="$(koopa_mktemp -d)"
    koopa_assert_is_dir "$x"
    koopa_print "$x"
    return 0
}

koopa_tmp_file() { # {{{1
    # """
    # Create temporary file.
    # @note Updated 2021-05-06.
    # """
    local x
    koopa_assert_has_no_args "$#"
    x="$(koopa_mktemp)"
    koopa_assert_is_file "$x"
    koopa_print "$x"
    return 0
}

koopa_tmp_log_file() { # {{{1
    # """
    # Create temporary log file.
    # @note Updated 2020-11-23.
    #
    # Used primarily for debugging installation scripts.
    #
    # Note that mktemp on macOS and BusyBox doesn't support '--suffix' flag.
    # Otherwise, we can use:
    # > koopa_mktemp --suffix='.log'
    # """
    koopa_assert_has_no_args "$#"
    koopa_tmp_file
    return 0
}

koopa_variables() { # {{{1
    # """
    # Edit koopa variables.
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_installed 'vim'
    vim "$(koopa_include_prefix)/variables.txt"
    return 0
}

koopa_view_latest_tmp_log_file() { # {{{1
    # """
    # View the latest temporary log file.
    # @note Updated 2022-01-17.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [tmp_dir]="${TMPDIR:-/tmp}"
        [user_id]="$(koopa_user_id)"
    )
    dict[log_file]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="koopa-${dict[user_id]}-*" \
            --prefix="${dict[tmp_dir]}" \
            --sort \
            --type='f' \
        | "${app[tail]}" -n 1 \
    )"
    if [[ ! -f "${dict[log_file]}" ]]
    then
        koopa_stop "No koopa log file detected in '${dict[tmp_dir]}'."
    fi
    koopa_alert "Viewing '${dict[log_file]}'."
    # The use of '+G' flag here forces pager to return at end of line.
    koopa_pager +G "${dict[log_file]}"
    return 0
}

koopa_warn_if_export() { # {{{1
    # """
    # Warn if variable is exported in current shell session.
    # @note Updated 2020-02-20.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_export "$arg"
        then
            koopa_warn "'${arg}' is exported."
        fi
    done
    return 0
}

koopa_which_function() { # {{{1
    # """
    # Locate a koopa function automatically.
    # @note Updated 2022-03-09.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [input_key]="${1:?}"
    )
    if koopa_is_function "${dict[input_key]}"
    then
        koopa_print "${dict[input_key]}"
        return 0
    fi
    dict[key]="${dict[input_key]//-/_}"
    dict[os_id]="$(koopa_os_id)"
    if koopa_is_function "koopa_${dict[os_id]}_${dict[key]}"
    then
        dict[fun]="koopa_${dict[os_id]}_${dict[key]}"
    elif koopa_is_rhel_like && \
        koopa_is_function "koopa_rhel_${dict[key]}"
    then
        dict[fun]="koopa_rhel_${dict[key]}"
    elif koopa_is_debian_like && \
        koopa_is_function "koopa_debian_${dict[key]}"
    then
        dict[fun]="koopa_debian_${dict[key]}"
    elif koopa_is_fedora_like && \
        koopa_is_function "koopa_fedora_${dict[key]}"
    then
        dict[fun]="koopa_fedora_${dict[key]}"
    elif koopa_is_linux && \
        koopa_is_function "koopa_linux_${dict[key]}"
    then
        dict[fun]="koopa_linux_${dict[key]}"
    else
        dict[fun]="koopa_${dict[key]}"
    fi
    koopa_is_function "${dict[fun]}" || return 1
    koopa_print "${dict[fun]}"
    return 0
}
