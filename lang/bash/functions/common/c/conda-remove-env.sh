#!/usr/bin/env bash

koopa_conda_remove_env() {
    # """
    # Remove conda environment.
    # @note Updated 2022-08-26.
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    #
    # @examples
    # > koopa_conda_remove_env 'kallisto' 'salmon'
    # """
    local -A app dict
    local name
    koopa_assert_has_args "$#"
    app['conda']="$(koopa_locate_conda)"
    koopa_assert_is_executable "${app[@]}"
    dict['nounset']="$(koopa_boolean_nounset)"
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for name in "$@"
    do
        dict['prefix']="$(koopa_conda_env_prefix "$name")"
        koopa_assert_is_dir "${dict['prefix']}"
        dict['name']="$(koopa_basename "${dict['prefix']}")"
        koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
        # Don't set the '--all' flag here; it can break other recipes.
        "${app['conda']}" env remove --name="${dict['name']}" --yes
        [[ -d "${dict['prefix']}" ]] && koopa_rm "${dict['prefix']}"
        koopa_alert_uninstall_success "${dict['name']}" "${dict['prefix']}"
    done
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}
