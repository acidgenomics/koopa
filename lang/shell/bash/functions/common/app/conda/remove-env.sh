#!/usr/bin/env bash

koopa::conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2022-01-17.
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    #
    # @examples
    # koopa::conda_remove_env 'kallisto' 'salmon'
    # """
    local app dict name
    koopa::assert_has_args "$#"
    declare -A app=(
        [conda]="$(koopa::locate_mamba_or_conda)"
    )
    declare -A dict=(
        [nounset]="$(koopa::boolean_nounset)"
    )
    [[ "${dict[nounset]}" -eq 1 ]] && set +u
    for name in "$@"
    do
        dict[prefix]="$(koopa::conda_env_prefix "$name")"
        koopa::assert_is_dir "${dict[prefix]}"
        dict[name]="$(koopa::basename "${dict[prefix]}")"
        koopa::alert_uninstall_start "${dict[name]}" "${dict[prefix]}"
        # Don't set the '--all' flag here; it can break other recipes.
        "${app[conda]}" env remove --name="${dict[name]}" --yes
        [[ -d "${dict[prefix]}" ]] && koopa::rm "${dict[prefix]}"
        koopa::alert_uninstall_success "${dict[name]}" "${dict[prefix]}"
    done
    [[ "${dict[nounset]}" -eq 1 ]] && set -u
    return 0
}
