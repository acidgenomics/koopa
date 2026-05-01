#!/usr/bin/env bash

main() {
    # """
    # Install BFG git repo cleaner.
    # @note Updated 2023-06-12.
    # """
    local -A app dict
    _koopa_activate_app 'temurin'
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['java']="$(_koopa_locate_java)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    dict['url']="https://search.maven.org/remotecontent?filepath=com/madgag/\
bfg/${dict['version']}/bfg-${dict['version']}.jar"
    _koopa_download "${dict['url']}" 'bfg.jar'
    _koopa_cp --target-directory="${dict['libexec']}" 'bfg.jar'
    dict['bin_file']="${dict['prefix']}/bin/bfg"
    _koopa_touch "${dict['bin_file']}"
    "${app['cat']}" > "${dict['bin_file']}" << END
#!/bin/sh
set -o errexit
set -o nounset

${app['java']} -jar "${dict['libexec']}/bfg.jar" "\$@"
END
    _koopa_chmod +x "${dict['bin_file']}"
    return 0
}
