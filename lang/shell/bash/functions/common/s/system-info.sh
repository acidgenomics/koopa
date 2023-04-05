#!/usr/bin/env bash

koopa_system_info() {
    # """
    # System information.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    local -a info nf_info
    koopa_assert_has_no_args "$#"
    app['bash']="$(koopa_locate_bash --allow-system)"
    app['cat']="$(koopa_locate_cat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['arch']="$(koopa_arch)"
    dict['arch2']="$(koopa_arch2)"
    dict['bash_version']="$(koopa_get_version "${app['bash']}")"
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['koopa_url']="$(koopa_koopa_url)"
    dict['koopa_version']="$(koopa_koopa_version)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['ascii_turtle_file']="${dict['koopa_prefix']}/etc/\
koopa/ascii-turtle.txt"
    koopa_assert_is_file "${dict['ascii_turtle_file']}"
    info=(
        "koopa ${dict['koopa_version']}"
        "URL: ${dict['koopa_url']}"
    )
    if koopa_is_git_repo_top_level "${dict['koopa_prefix']}"
    then
        dict['git_remote']="$(koopa_git_remote_url "${dict['koopa_prefix']}")"
        dict['git_commit']="$( \
            koopa_git_last_commit_local "${dict['koopa_prefix']}" \
        )"
        dict['git_date']="$(koopa_git_commit_date "${dict['koopa_prefix']}")"
        info+=(
            ''
            'Git repo'
            '--------'
            "Remote: ${dict['git_remote']}"
            "Commit: ${dict['git_commit']}"
            "Date: ${dict['git_date']}"
        )
    fi
    info+=(
        ''
        'Configuration'
        '-------------'
        "Koopa Prefix: ${dict['koopa_prefix']}"
        "App Prefix: ${dict['app_prefix']}"
        "Opt Prefix: ${dict['opt_prefix']}"
        "Config Prefix: ${dict['config_prefix']}"
    )
    if koopa_is_macos
    then
        app['sw_vers']="$(koopa_macos_locate_sw_vers)"
        [[ -x "${app['sw_vers']}" ]] || exit 1
        dict['os']="$( \
            printf '%s %s (%s)\n' \
                "$("${app['sw_vers']}" -productName)" \
                "$("${app['sw_vers']}" -productVersion)" \
                "$("${app['sw_vers']}" -buildVersion)" \
        )"
    else
        app['uname']="$(koopa_locate_uname --allow-system)"
        [[ -x "${app['uname']}" ]] || exit 1
        dict['os']="$("${app['uname']}" --all)"
    fi
    info+=(
        ''
        'System information'
        '------------------'
        "OS: ${dict['os']}"
        "Architecture: ${dict['arch']} / ${dict['arch2']}"
        "Bash: ${dict['bash_version']}"
    )
    if koopa_is_installed 'neofetch'
    then
        app['neofetch']="$(koopa_locate_neofetch)"
        [[ -x "${app['neofetch']}" ]] || exit 1
        readarray -t nf_info <<< "$("${app['neofetch']}" --stdout)"
        info+=(
            ''
            'Neofetch'
            '--------'
            "${nf_info[@]:2}"
        )
    fi
    "${app['cat']}" "${dict['ascii_turtle_file']}"
    koopa_info_box "${info[@]}"
    return 0
}
