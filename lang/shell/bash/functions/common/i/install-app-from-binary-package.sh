#!/usr/bin/env bash

koopa_install_app_from_binary_package() {
    # """
    # Install app from pre-built binary package.
    # @note Updated 2022-08-30.
    #
    # @examples
    # > koopa_install_app_from_binary_package \
    # >     '/opt/koopa/app/aws-cli/2.7.7' \
    # >     '/opt/koopa/app/bash/5.1.16'
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app
    app['tar']="$(koopa_locate_tar --allow-system)"
    [[ -x "${app['tar']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['binary_prefix']='/opt/koopa'
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['os_string']="$(koopa_os_string)"
        ['url_stem']="$(koopa_koopa_url)/app"
    )
    if [[ "${dict['koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local dict2
        declare -A dict2
        dict2['prefix']="$(koopa_realpath "$prefix")"
        dict2['name']="$( \
            koopa_print "${dict2['prefix']}" \
                | koopa_dirname \
                | koopa_basename \
        )"
        dict2['version']="$(koopa_basename "$prefix")"
        dict2['tar_file']="${dict2['name']}-${dict2['version']}.tar.gz"
        dict2['tar_url']="${dict['url_stem']}/${dict['os_string']}/${dict['arch']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        if ! koopa_is_url_active "${dict2['tar_url']}"
        then
            koopa_stop "No package at '${dict2['tar_url']}'."
        fi
        koopa_download "${dict2['tar_url']}" "${dict2['tar_file']}"
        "${app['tar']}" -Pxzf "${dict2['tar_file']}"
        koopa_touch "${prefix}/.koopa-binary"
    done
    return 0
}
