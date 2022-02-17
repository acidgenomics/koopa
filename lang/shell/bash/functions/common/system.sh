#!/usr/bin/env bash

koopa::exec_dir() { # {{{1
    # """
    # Execute multiple shell scripts in a directory.
    # @note Updated 2022-01-20.
    # """
    local file prefix
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        koopa::assert_is_dir "$prefix"
        for file in "${prefix}/"*'.sh'
        do
            [ -x "$file" ] || continue
            # shellcheck source=/dev/null
            "$file"
        done
    done
    return 0
}

koopa::header() { # {{{1
    # """
    # Shared language-specific header file.
    # @note Updated 2022-02-15.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 1
    declare -A dict=(
        [lang]="$(koopa::lowercase "${1:?}")"
        [prefix]="$(koopa::koopa_prefix)/lang"
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
            koopa::invalid_arg "${dict[lang]}"
            ;;
    esac
    dict[file]="${dict[prefix]}/${dict[lang]}/include/header.${dict[ext]}"
    koopa::assert_is_file "${dict[file]}"
    koopa::print "${dict[file]}"
    return 0
}

koopa::help() { # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2022-02-15.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [head]="$(koopa::locate_head)"
        [man]="$(koopa::locate_man)"
    )
    declare -A dict=(
        [man_file]="${1:?}"
    )
    koopa::assert_is_file "${dict[man_file]}"
    "${app[head]}" -n 10 "${dict[man_file]}" \
        | koopa::str_detect_fixed - --pattern='.TH ' \
        || koopa::stop "Invalid documentation at '${dict[man_file]}'."
    "${app[man]}" "${dict[man_file]}"
    exit 0
}

koopa::info_box() { # {{{1
    # """
    # Configuration information box.
    # @note Updated 2021-03-30.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    # """
    koopa::assert_has_args "$#"
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

koopa::mktemp() { # {{{1
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
        [mktemp]="$(koopa::locate_mktemp)"
    )
    declare -A dict=(
        [date_id]="$(koopa::datetime)"
        [user_id]="$(koopa::user_id)"
    )
    dict[template]="koopa-${dict[user_id]}-${dict[date_id]}-XXXXXXXXXX"
    mktemp_args=(
        "$@"
        '-t' "${dict[template]}"
    )
    str="$("${app[mktemp]}" "${mktemp_args[@]}")"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::pager() { # {{{1
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2022-02-15.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local app args
    koopa::assert_has_args "$#"
    declare -A app=(
        [less]="$(koopa::locate_less)"
    )
    args=("$@")
    koopa::assert_is_file "${args[-1]}"
    "${app[less]}" -R "${args[@]}"
    return 0
}

koopa::roff() { # {{{1
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2022-02-17.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [ronn]="$(koopa::locate_ronn)"
    )
    declare -A app=(
        [man_prefix]="$(koopa::man_prefix)"
    )
    (
        koopa::cd "${dict[man_prefix]}"
        "${app[ronn]}" --roff ./*'.ronn'
        koopa::mv --target-directory='man1' ./*'.1'
    )
    return 0
}

koopa::run_if_installed() { # {{{1
    # """
    # Run program(s) if installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        local exe
        if ! koopa::is_installed "$arg"
        then
            koopa::alert_note "Skipping '${arg}'."
            continue
        fi
        exe="$(koopa::which_realpath "$arg")"
        "$exe"
    done
    return 0
}

koopa::source_dir() { # {{{1
    # """
    # Source multiple shell scripts in a directory.
    # @note Updated 2022-02-17.
    # """
    local file prefix
    koopa::assert_has_args_eq "$#" 1
    prefix="${1:?}"
    koopa::assert_is_dir "$prefix"
    for file in "${prefix}/"*'.sh'
    do
        [[ -f "$file" ]] || continue
        # shellcheck source=/dev/null
        . "$file"
    done
    return 0
}

koopa::switch_to_develop() {  # {{{1
    # """
    # Switch koopa install to development version.
    # @note Updated 2022-02-14.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [branch]='develop'
        [origin]='origin'
        [prefix]="$(koopa::koopa_prefix)"
    )
    koopa::alert "Switching koopa at '${dict[prefix]}' to '${dict[branch]}'."
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    (
        koopa::cd "${dict[prefix]}"
        "${app[git]}" checkout \
            -B "${dict[branch]}" \
            "${dict[origin]}/${dict[branch]}"
    )
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    koopa::fix_zsh_permissions
    return 0
}

koopa::sys_chgrp() { # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local chgrp group
    koopa::assert_has_args "$#"
    group="$(koopa::sys_group)"
    chgrp=('koopa::chgrp')
    if koopa::is_shared_install
    then
        chgrp+=('--sudo')
    fi
    "${chgrp[@]}" "$group" "$@"
    return 0
}

koopa::sys_chmod() { # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local chmod
    koopa::assert_has_args "$#"
    chmod=('koopa::chmod')
    if koopa::is_shared_install
    then
        chmod+=('--sudo')
    fi
    "${chmod[@]}" "$@"
    return 0
}

koopa::sys_chown() { # {{{1
    # """
    # chown with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local chown
    koopa::assert_has_args "$#"
    chown=('koopa::chown')
    if koopa::is_shared_install
    then
        chown+=('--sudo')
    fi
    "${chown[@]}" "$@"
    return 0
}

koopa::sys_cp() { # {{{1
    # """
    # Koopa copy.
    # @note Updated 2021-09-20.
    # """
    local cp
    koopa::assert_has_args "$#"
    cp=('koopa::cp')
    if koopa::is_shared_install
    then
        cp+=('--sudo')
    fi
    "${cp[@]}" "$@"
    return 0
}

koopa::sys_group() { # {{{1
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
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        group="$(koopa::admin_group)"
    else
        group="$(koopa::group)"
    fi
    koopa::print "$group"
    return 0
}

koopa::sys_ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2021-09-20.
    #
    # Don't need to set 'g+rw' for symbolic link here.
    # Symlink permissions are ignored on most systems, including Linux.
    #
    # On macOS, you can override using BSD ln:
    # > /bin/ln -h g+rw <file>
    # """
    local ln source target
    koopa::assert_has_args_eq "$#" 2
    source="${1:?}"
    target="${2:?}"
    ln=('koopa::ln')
    if koopa::is_shared_install
    then
        ln+=('--sudo')
    fi
    "${ln[@]}" "$source" "$target"
    koopa::sys_set_permissions --no-dereference "$target"
    return 0
}

koopa::sys_mkdir() { # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local mkdir
    koopa::assert_has_args "$#"
    mkdir=('koopa::mkdir')
    if koopa::is_shared_install
    then
        mkdir+=('--sudo')
    fi
    "${mkdir[@]}" "$@"
    koopa::sys_set_permissions "$@"
    return 0
}

koopa::sys_mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2021-09-20.
    # """
    local mv
    koopa::assert_has_args "$#"
    mv=('koopa::mv')
    if koopa::is_shared_install
    then
        mv+=('--sudo')
    fi
    "${mv[@]}" "$@"
    return 0
}

koopa::sys_rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2021-09-20.
    # """
    local rm
    koopa::assert_has_args "$#"
    rm=('koopa::rm')
    if koopa::is_shared_install
    then
        rm+=('--sudo')
    fi
    "${rm[@]}" "$@"
    return 0
}

koopa::sys_set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2022-02-15.
    #
    # Consider ensuring that nested directories are also executable.
    # e.g. 'app/julia-packages/1.6/registries/General'.
    # """
    koopa::assert_has_args "$#"
    local arg chmod chown dict group pos user
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [user]=0
    )
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
                dict[user]=1
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    case "${dict[user]}" in
        '0')
            chmod=('koopa::sys_chmod')
            chown=('koopa::sys_chown')
            group="$(koopa::sys_group)"
            user="$(koopa::sys_user)"
            ;;
        '1')
            chmod=('koopa::chmod')
            chown=('koopa::chown')
            group="$(koopa::group)"
            user="$(koopa::user)"
            ;;
    esac
    chown+=('--no-dereference')
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod+=('--recursive')
        chown+=('--recursive')
    fi
    if koopa::is_shared_install
    then
        chmod+=('u+rw,g+rw,o+r,o-w')
    else
        chmod+=('u+rw,g+r,g-w,o+r,o-w')
    fi
    chown+=("${user}:${group}")
    for arg in "$@"
    do
        if [[ "${dict[dereference]}" -eq 1 ]] && [[ -L "$arg" ]]
        then
            arg="$(koopa::realpath "$arg")"
        fi
        "${chmod[@]}" "$arg"
        "${chown[@]}" "$arg"
    done
    return 0
}

koopa::sys_user() { # {{{1
    # """
    # Set the koopa installation system user.
    # @note Updated 2020-07-06.
    # """
    local user
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        user='root'
    else
        user="$(koopa::user)"
    fi
    koopa::print "$user"
    return 0
}

koopa::system_info() { # {{{
    # """
    # System information.
    # @note Updated 2022-01-25.
    # """
    local app dict info nf_info
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
        [cat]="$(koopa::locate_cat)"
    )
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [arch]="$(koopa::arch)"
        [arch2]="$(koopa::arch2)"
        [ascii_turtle_file]="$(koopa::include_prefix)/ascii-turtle.txt"
        [bash_version]="$(koopa::get_version "${app[bash]}")"
        [config_prefix]="$(koopa::config_prefix)"
        [koopa_date]="$(koopa::koopa_date)"
        [koopa_github_url]="$(koopa::koopa_github_url)"
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [koopa_url]="$(koopa::koopa_url)"
        [koopa_version]="$(koopa::koopa_version)"
        [make_prefix]="$(koopa::make_prefix)"
        [opt_prefix]="$(koopa::opt_prefix)"
    )
    info=(
        "koopa ${dict[koopa_version]} (${dict[koopa_date]})"
        "URL: ${dict[koopa_url]}"
        "GitHub URL: ${dict[koopa_github_url]}"
    )
    if koopa::is_git_repo_top_level "${dict[koopa_prefix]}"
    then
        dict[remote]="$(koopa::git_remote_url "${dict[koopa_prefix]}")"
        dict[commit]="$(koopa::git_last_commit_local "${dict[koopa_prefix]}")"
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
    if koopa::is_macos
    then
        app[sw_vers]="$(koopa::macos_locate_sw_vers)"
        dict[os]="$( \
            printf '%s %s (%s)\n' \
                "$("${app[sw_vers]}" -productName)" \
                "$("${app[sw_vers]}" -productVersion)" \
                "$("${app[sw_vers]}" -buildVersion)" \
        )"
    else
        app[uname]="$(koopa::locate_uname)"
        dict[os]="$("${app[uname]}" --all)"
        # Alternate approach using Python:
        # > app[python]="$(koopa::locate_python)"
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
    if koopa::is_installed 'neofetch'
    then
        app[neofetch]="$(koopa::locate_neofetch)"
        readarray -t nf_info <<< "$("${app[neofetch]}" --stdout)"
        info+=(
            ''
            'Neofetch'
            '--------'
            "${nf_info[@]:2}"
        )
    fi
    "${app[cat]}" "${dict[ascii_turtle_file]}"
    koopa::info_box "${info[@]}"
    return 0
}

koopa::tmp_dir() { # {{{1
    # """
    # Create temporary directory.
    # @note Updated 2020-05-06.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="$(koopa::mktemp -d)"
    koopa::assert_is_dir "$x"
    koopa::print "$x"
    return 0
}

koopa::tmp_file() { # {{{1
    # """
    # Create temporary file.
    # @note Updated 2021-05-06.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="$(koopa::mktemp)"
    koopa::assert_is_file "$x"
    koopa::print "$x"
    return 0
}

koopa::tmp_log_file() { # {{{1
    # """
    # Create temporary log file.
    # @note Updated 2020-11-23.
    #
    # Used primarily for debugging installation scripts.
    #
    # Note that mktemp on macOS and BusyBox doesn't support '--suffix' flag.
    # Otherwise, we can use:
    # > koopa::mktemp --suffix='.log'
    # """
    koopa::assert_has_no_args "$#"
    koopa::tmp_file
    return 0
}

koopa::variables() { # {{{1
    # """
    # Edit koopa variables.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'vim'
    vim "$(koopa::include_prefix)/variables.txt"
    return 0
}

koopa::view_latest_tmp_log_file() { # {{{1
    # """
    # View the latest temporary log file.
    # @note Updated 2022-01-17.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [tmp_dir]="${TMPDIR:-/tmp}"
        [user_id]="$(koopa::user_id)"
    )
    dict[log_file]="$( \
        koopa::find \
            --glob="koopa-${dict[user_id]}-*" \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[tmp_dir]}" \
            --sort \
            --type='f' \
        | "${app[tail]}" -n 1 \
    )"
    if [[ ! -f "${dict[log_file]}" ]]
    then
        koopa::stop "No koopa log file detected in '${dict[tmp_dir]}'."
    fi
    koopa::alert "Viewing '${dict[log_file]}'."
    # The use of '+G' flag here forces pager to return at end of line.
    koopa::pager +G "${dict[log_file]}"
    return 0
}

koopa::warn_if_export() { # {{{1
    # """
    # Warn if variable is exported in current shell session.
    # @note Updated 2020-02-20.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_export "$arg"
        then
            koopa::warn "'${arg}' is exported."
        fi
    done
    return 0
}

koopa::which_function() { # {{{1
    # """
    # Locate a koopa function automatically.
    # @note Updated 2022-02-16.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 1
    declare -A dict=(
        [input_key]="${1:?}"
    )
    if koopa::is_function "${dict[input_key]}"
    then
        koopa::print "${dict[input_key]}"
        return 0
    fi
    dict[key]="${dict[input_key]//-/_}"
    dict[os_id]="$(koopa::os_id)"
    if koopa::is_function "koopa::${dict[os_id]}_${dict[key]}"
    then
        dict[fun]="koopa::${dict[os_id]}_${dict[key]}"
    elif koopa::is_rhel_like && \
        koopa::is_function "koopa::rhel_${dict[key]}"
    then
        dict[fun]="koopa::rhel_${dict[key]}"
    elif koopa::is_debian_like && \
        koopa::is_function "koopa::debian_${dict[key]}"
    then
        dict[fun]="koopa::debian_${dict[key]}"
    elif koopa::is_fedora_like && \
        koopa::is_function "koopa::fedora_${dict[key]}"
    then
        dict[fun]="koopa::fedora_${dict[key]}"
    elif koopa::is_linux && \
        koopa::is_function "koopa::linux_${dict[key]}"
    then
        dict[fun]="koopa::linux_${dict[key]}"
    else
        dict[fun]="koopa::${dict[key]}"
    fi
    koopa::is_function "${dict[fun]}" || return 1
    koopa::print "${dict[fun]}"
    return 0
}
