#!/usr/bin/env bash

_koopa_system_info() {
    # """
    # System information.
    # @note Updated 2025-12-11.
    # """
    local -A app dict
    local -a info nf_info
    _koopa_assert_has_no_args "$#"
    app['bash']="$(_koopa_locate_bash --allow-bootstrap --realpath)"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['python']="$(_koopa_locate_python --allow-bootstrap --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch)"
    dict['arch2']="$(_koopa_arch2)"
    dict['bash_version']="$(_koopa_get_version "${app['bash']}")"
    dict['config_prefix']="$(_koopa_config_prefix)"
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['_koopa_url']="$(_koopa_koopa_url)"
    dict['_koopa_version']="$(_koopa_koopa_version)"
    dict['python_version']="$(_koopa_get_version "${app['python']}")"
    dict['ascii_turtle_file']="${dict['_koopa_prefix']}/etc/\
koopa/ascii-turtle.txt"
    _koopa_assert_is_file "${dict['ascii_turtle_file']}"
    info=(
        "koopa ${dict['_koopa_version']}"
        "URL: ${dict['_koopa_url']}"
    )
    if _koopa_is_git_repo_top_level "${dict['_koopa_prefix']}"
    then
        dict['git_remote']="$(_koopa_git_remote_url "${dict['_koopa_prefix']}")"
        dict['git_commit']="$( \
            _koopa_git_last_commit_local "${dict['_koopa_prefix']}" \
        )"
        dict['git_date']="$(_koopa_git_commit_date "${dict['_koopa_prefix']}")"
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
        "Koopa Prefix: ${dict['_koopa_prefix']}"
        "Config Prefix: ${dict['config_prefix']}"
    )
    if _koopa_is_macos
    then
        app['sw_vers']="$(_koopa_macos_locate_sw_vers)"
        _koopa_assert_is_executable "${app['sw_vers']}"
        dict['os']="$( \
            printf '%s %s (%s)\n' \
                "$("${app['sw_vers']}" -productName)" \
                "$("${app['sw_vers']}" -productVersion)" \
                "$("${app['sw_vers']}" -buildVersion)" \
        )"
    else
        app['uname']="$(_koopa_locate_uname --allow-system)"
        _koopa_assert_is_executable "${app['uname']}"
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
    app['neofetch']="$(_koopa_locate_neofetch --allow-missing)"
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
    _koopa_info_box "${info[@]}"
    return 0
}
