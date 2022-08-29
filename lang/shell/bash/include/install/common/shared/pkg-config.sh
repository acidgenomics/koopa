#!/usr/bin/env bash

main() {
    # """
    # Install pkg-config.
    # @note Updated 2022-08-29.
    #
    # Requires cmp and diff to be installed.
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['make']="$(koopa_locate_make --allow-missing)"
    )
    [[ -x "${app['make']}" ]] && app['make']='/usr/bin/make'
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='pkg-config'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://${dict['name']}.freedesktop.org/releases/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['sys_inc']='/usr/include'
    if koopa_is_macos
    then
        dict['sdk_prefix']="$(koopa_macos_sdk_prefix)"
        dict['sys_inc']="${dict['sdk_prefix']}/${dict['sys_inc']}"
    fi
    koopa_assert_is_dir "${dict['sys_inc']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--disable-host-tool'
        '--with-internal-glib'
        "--with-system-include-path=${dict['sys_inc']}"
    )
    if koopa_is_macos
    then
        dict['pc_path']='/usr/lib/pkgconfig'
        conf_args+=("--with-pc-path=${dict['pc_path']}")
    fi
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
