#!/usr/bin/env bash

koopa_system_info() {
    # """
    # System information.
    # @note Updated 2025-08-21.
    # """
    local -A app dict
    local -a info nf_info
    koopa_assert_has_no_args "$#"
    app['bash']="$( \
        koopa_locate_bash --allow-bootstrap --allow-system --realpath \
    )"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['python']="$( \
        koopa_locate_python --allow-bootstrap --allow-system --realpath \
    )"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    dict['arch2']="$(koopa_arch2)"
    dict['bash_version']="$(koopa_get_version "${app['bash']}")"
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['koopa_url']="$(koopa_koopa_url)"
    dict['koopa_version']="$(koopa_koopa_version)"
    dict['python_version']="$(koopa_get_version "${app['python']}")"
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
        "Config Prefix: ${dict['config_prefix']}"
    )
    if koopa_is_macos
    then
        app['sw_vers']="$(koopa_macos_locate_sw_vers)"
        koopa_assert_is_executable "${app['sw_vers']}"
        dict['os']="$( \
            printf '%s %s (%s)\n' \
                "$("${app['sw_vers']}" -productName)" \
                "$("${app['sw_vers']}" -productVersion)" \
                "$("${app['sw_vers']}" -buildVersion)" \
        )"
    else
        app['uname']="$(koopa_locate_uname --allow-system)"
        koopa_assert_is_executable "${app['uname']}"
        dict['os']="$("${app['uname']}" --all)"
    fi
    info+=(
        ''
        'System information'
        '------------------'
        "OS: ${dict['os']}"
        "Architecture: ${dict['arch']} / ${dict['arch2']}"
        "Bash: ${app['bash']}"
        "Bash Version: ${dict['bash_version']}"
        "Python: ${app['python']}"
        "Python Version: ${dict['python_version']}"
    )
    app['neofetch']="$(koopa_locate_neofetch --allow-missing)"
    if [[ -x "${app['neofetch']}" ]]
    then
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
