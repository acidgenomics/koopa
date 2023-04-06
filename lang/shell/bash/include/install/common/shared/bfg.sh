#!/usr/bin/env bash

main() {
    # """
    # Install BFG git repo cleaner.
    # @note Updated 2023-03-27.
    # """
    local -A app dict
    koopa_activate_app 'openjdk'
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['java']="$(koopa_locate_java)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='bfg'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
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
