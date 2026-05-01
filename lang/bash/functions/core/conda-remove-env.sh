#!/usr/bin/env bash

_koopa_conda_remove_env() {
    # """
    # Remove conda environment.
    # @note Updated 2022-08-26.
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    #
    # @examples
    # > _koopa_conda_remove_env 'kallisto' 'salmon'
    # """
    local -A app dict
    local name
    _koopa_assert_has_args "$#"
    app['conda']="$(_koopa_locate_conda)"
    _koopa_assert_is_executable "${app[@]}"
    dict['nounset']="$(_koopa_boolean_nounset)"
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for name in "$@"
    do
        dict['prefix']="$(_koopa_conda_env_prefix "$name")"
        _koopa_assert_is_dir "${dict['prefix']}"
        dict['name']="$(_koopa_basename "${dict['prefix']}")"
        _koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
        # Don't set the '--all' flag here; it can break other recipes.
        "${app['conda']}" env remove --name="${dict['name']}" --yes
        [[ -d "${dict['prefix']}" ]] && _koopa_rm "${dict['prefix']}"
        _koopa_alert_uninstall_success "${dict['name']}" "${dict['prefix']}"
    done
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}
