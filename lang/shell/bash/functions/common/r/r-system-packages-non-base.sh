#!/usr/bin/env bash

koopa_r_system_packages_non_base() {
    # """
    # Print non-base packages (i.e. "recommended") installed in system library.
    # @note Updated 2023-04-04.
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || exit 1
    [[ -x "${app['rscript']}" ]] || exit 1
    dict['script']="$(koopa_koopa_prefix)/lang/r/system-packages-non-base.R"
    koopa_assert_is_file "${dict['script']}"
    dict['string']="$("${app['rscript']}" --vanilla "${dict['script']}")"
    [[ -n "${dict['string']}" ]] || return 0
    koopa_print "${dict['string']}"
    return 0
}
