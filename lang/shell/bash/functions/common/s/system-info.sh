#!/usr/bin/env bash

koopa_system_info() {
    # """
    # System information.
    # @note Updated 2022-06-15.
    # """
    local app dict info nf_info
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
        [cat]="$(koopa_locate_cat)"
    )
    [[ -x "${app[bash]}" ]] || return 1
    [[ -x "${app[cat]}" ]] || return 1
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
