#!/usr/bin/env bash

koopa_configure_python() { #{{{1
    # """
    # Configure Python.
    # @note Updated 2021-11-30.
    #
    # This creates a Python 'site-packages' directory and then links using
    # a 'koopa.pth' file into the Python system 'site-packages'.
    #
    # @seealso
    # > "$python" -m site
    # """
    local app dict
    declare -A app=(
        [python]="${1:-}"
    )
    if [[ -z "${app[python]}" ]]
    then
        app[python]="$(koopa_locate_python)"
    fi
    koopa_assert_is_installed "${app[python]}"
    declare -A dict=(
        [version]="$(koopa_get_version "${app[python]}")"
    )
    dict[sys_site_pkgs]="$( \
        koopa_python_system_packages_prefix "${app[python]}" \
    )"
    dict[k_site_pkgs]="$(koopa_python_packages_prefix "${dict[version]}")"
    dict[pth_file]="${dict[sys_site_pkgs]}/koopa.pth"
    koopa_alert "Adding '${dict[pth_file]}' path file."
    if koopa_is_koopa_app "${app[python]}"
    then
        app[write_string]='koopa_write_string'
    else
        app[write_string]='koopa_sudo_write_string'
    fi
    "${app[write_string]}" "${dict[k_site_pkgs]}" "${dict[pth_file]}"
    koopa_configure_app_packages \
        --name-fancy='Python' \
        --name='python' \
        --prefix="${dict[k_site_pkgs]}"
    return 0
}
