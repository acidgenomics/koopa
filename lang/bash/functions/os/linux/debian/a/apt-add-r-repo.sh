#!/usr/bin/env bash

koopa_debian_apt_add_r_repo() {
    # """
    # Add R apt repo.
    # @note Updated 2025-02-14.
    # """
    local -A dict
    koopa_assert_has_args_le "$#" 1
    dict['name']='r'
    dict['os_codename']="$(koopa_debian_os_codename)"
    dict['version']="${1:-}"
    if koopa_is_ubuntu_like
    then
        dict['os_id']='ubuntu'
    else
        dict['os_id']='debian'
    fi
    if [[ -z "${dict['version']}" ]]
    then
        dict['version']="$(koopa_app_json_version "${dict['name']}")"
    fi
    dict['version2']="$(koopa_major_minor_version "${dict['version']}")"
    case "${dict['version2']}" in
        '4.'*)
            dict['version2']='4.0'
            ;;
        '3.'*)
            dict['version2']='3.5'
            ;;
    esac
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "${dict['version2']}" \
    )"
    dict['url']="https://cloud.r-project.org/bin/linux/${dict['os_id']}"
    dict['distribution']="${dict['os_codename']}-cran${dict['version2']}/"
    koopa_debian_apt_add_r_key || true
    koopa_debian_apt_add_repo \
        --distribution="${dict['distribution']}" \
        --name="${dict['name']}" \
        --url="${dict['url']}"
    return 0
}
