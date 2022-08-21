#!/usr/bin/env bash

# FIXME Take this out.
# FIXME Rework this to just locate the 'site-library' inside the package.

koopa_r_packages_prefix() {
    # """
    # R site library prefix.
    # @note Updated 2022-07-27.
    #
    # @usage
    # > koopa_r_packages_prefix '/opt/koopa/bin/R'
    # # /opt/koopa/app/r-packages/4.2
    # > koopa_r_packages_prefix '/opt/koopa/bin/R-devel'
    # # /opt/koopa/app/r-packages/devel
    # """
    local app dict
    declare -A app
    app['r']="${1:?}"
    declare -A dict
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['name']='r-packages'
    dict['version']="$(koopa_r_version "${app['r']}")"
    if [[ "${dict['version']}" != 'devel' ]]
    then
        dict['version']="$(koopa_major_minor_version "${dict['version']}")"
    fi
    dict['str']="${dict['app_prefix']}/${dict['name']}/${dict['version']}"
    koopa_print "${dict['str']}"
    return 0
}
