#!/usr/bin/env bash

koopa_r_remove_packages_in_system_library() {
    # """
    # Install packages into R site library.
    # @note Updated 2024-05-28.
    # """
    local -A app bool dict
    local -a rscript_cmd
    koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    shift 1
    bool['system']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    dict['script']="$(koopa_r_scripts_prefix)/\
remove-packages-in-system-library.R"
    koopa_assert_is_executable "${dict['script']}"
    rscript_cmd=()
    if [[ "${bool['system']}" -eq 1 ]]
    then
        rscript_cmd+=('koopa_sudo')
    fi
    rscript_cmd+=("${app['rscript']}")
    "${rscript_cmd[@]}" "${dict['script']}" "$@"
    return 0
}
