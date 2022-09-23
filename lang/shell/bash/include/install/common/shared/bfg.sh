#!/usr/bin/env bash

main() {
    # """
    # Install BFG git repo cleaner.
    # @note Updated 2022-09-22.
    # """
    local app dict
    koopa_activate_opt_prefix 'openjdk'
    declare -A app=(
        ['cat']="$(koopa_locate_cat)"
        ['java']="$(koopa_locate_java)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['java']}" ]] || return 1
    declare -A dict=(
        ['name']='bfg'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['file']="${dict['name']}-${dict['version']}.jar"
    dict['url']="https://search.maven.org/remotecontent?filepath=com/madgag/\
${dict['name']}/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_cp --target-directory="${dict['libexec']}" "${dict['file']}"
    dict['bin_file']="${dict['prefix']}/bin/bfg"
    koopa_touch "${dict['bin_file']}"
    "${app['cat']}" > "${dict['bin_file']}" << END
#!/bin/sh

${app['java']} -jar "${dict['libexec']}/${dict['file']}" "\$@"
END
    koopa_chmod +x "${dict['bin_file']}"
    return 0
}
