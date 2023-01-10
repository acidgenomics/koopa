#!/usr/bin/env bash

koopa_debian_apt_add_llvm_repo() {
    # """
    # Add LLVM apt repo.
    # @note Updated 2022-08-24.
    # """
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        ['component']='main'
        ['name']='llvm'
        ['os']="$(koopa_debian_os_codename)"
        ['version']="${1:-}"
    )
    if [[ -z "${dict['version']}" ]]
    then
        dict['version']="$(koopa_app_json_version "${dict['name']}")"
    fi
    dict['url']="http://apt.llvm.org/${dict['os']}/"
    dict['version2']="$(koopa_major_version "${dict['version']}")"
    dict['distribution']="llvm-toolchain-${dict['os']}-${dict['version2']}"
    koopa_debian_apt_add_llvm_key
    koopa_debian_apt_add_repo \
        --component="${dict['component']}" \
        --distribution="${dict['distribution']}" \
        --name="${dict['name']}" \
        --url="${dict['url']}"
    return 0
}
