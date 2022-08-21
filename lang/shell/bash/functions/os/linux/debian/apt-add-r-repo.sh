#!/usr/bin/env bash

koopa_debian_apt_add_r_repo() {
    # """
    # Add R apt repo.
    # @note Updated 2022-07-15.
    # """
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        ['name']='r'
        ['os_codename']="$(koopa_os_codename)"
        ['version']="${1:-}"
    )
    if koopa_is_ubuntu_like
    then
        dict['os_id']='ubuntu'
    else
        dict['os_id']='debian'
    fi
    if [[ -z "${dict['version']}" ]]
    then
        dict['version']="$(koopa_variable "${dict['name']}")"
    fi
    dict['version2']="$(koopa_major_minor_version "${dict['version']}")"
    case "${dict['version2']}" in
        '4.1' | \
        '4.2')
            dict['version2']='4.0'
            ;;
        '3.6')
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
    koopa_debian_apt_add_r_key
    koopa_debian_apt_add_repo \
        --distribution="${dict['distribution']}" \
        --name="${dict['name']}" \
        --url="${dict['url']}"
    return 0
}
