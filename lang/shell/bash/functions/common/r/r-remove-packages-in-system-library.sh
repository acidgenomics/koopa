#!/usr/bin/env bash

koopa_r_remove_packages_in_system_library() {
    # """
    # Install packages into R site library.
    # @note Updated 2023-04-04.
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || exit 1
    [[ -x "${app['rscript']}" ]] || exit 1
    shift 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    dict['script']="$(koopa_koopa_prefix)/lang/r/\
remove-packages-in-system-library.R"
    koopa_assert_is_file "${dict['script']}"
    case "${dict['system']}" in
        '0')
            "${app['rscript']}" "${dict['script']}" "$@"
            ;;
        '1')
            app['sudo']="$(koopa_locate_sudo)"
            [[ -x "${app['sudo']}" ]] || exit 1
            "${app['sudo']}" "${app['rscript']}" "${dict['script']}" "$@"
            ;;
    esac
    return 0
}
