#!/usr/bin/env bash

koopa_r_remove_packages_in_system_library() {
    # """
    # Install packages into R site library.
    # @note Updated 2023-05-18.
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
    koopa_warn "FIXME SYSTEM: ${bool['system']}"
    dict['script']="$(koopa_koopa_prefix)/lang/r/\
remove-packages-in-system-library.R"
    koopa_assert_is_file "${dict['script']}"
    rscript_cmd=()
    if [[ "${bool['system']}" -eq 1 ]]
    then
        rscript_cmd+=('koopa_sudo')
    fi
    rscript_cmd+=("${app['rscript']}")
    koopa_assert_is_executable "${app[@]}"
    "${rscript_cmd[@]}" "${dict['script']}" "$@"
    return 0
}
