#!/usr/bin/env bash

main() {
    # """
    # Install LuaJIT.
    # @note Updated 2024-12-30.
    #
    # @seealso
    # - https://luajit.org/download.html
    # - https://luajit.org/install.html
    # """
    local -A app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    app['pkg_config']="$(koopa_locate_pkg_config)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/LuaJIT/LuaJIT/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    if koopa_is_macos
    then
        dict['macos_version']="$(koopa_macos_os_version)"
        MACOSX_DEPLOYMENT_TARGET="${dict['macos_version']}"
        export MACOSX_DEPLOYMENT_TARGET
    fi
    koopa_print_env
    "${app['make']}" PREFIX="${dict['prefix']}"
    "${app['make']}" install PREFIX="${dict['prefix']}"
    dict['pc_file']="${dict['prefix']}/lib/pkgconfig/luajit.pc"
    koopa_assert_is_file "${dict['pc_file']}"
    dict['llj_min_maj_ver']="$( \
        "${app['pkg_config']}" --variable='abiver' "${dict['pc_file']}" \
    )"
    (
        [[ -x "${dict['prefix']}/bin/luajit" ]] && return 0
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln "luajit-${dict['version']}" 'luajit'
    )
    (
        koopa_cd "${dict['prefix']}/lib"
        # e.g. 'libluajit-5.1.a' to 'libluajit.a'.
        koopa_ln \
            "libluajit-${dict['llj_min_maj_ver']}.a" \
            'libluajit.a'
        if koopa_is_macos
        then
            # e.g. 'libluajit-5.1.dylib' to 'libluajit.dylib'.
            koopa_ln \
                "libluajit-${dict['llj_min_maj_ver']}.${dict['shared_ext']}" \
                "libluajit.${dict['shared_ext']}"
        else
            dict['majver']="$( \
                "${app['pkg_config']}" \
                    --variable='majver' "${dict['pc_file']}" \
            )"
            dict['minver']="$( \
                "${app['pkg_config']}" \
                    --variable='minver' "${dict['pc_file']}" \
            )"
            dict['relver']="$( \
                "${app['pkg_config']}" \
                    --variable='relver' "${dict['pc_file']}" \
            )"
            # e.g. 'libluajit-5.1.so.2.1.0' to 'libluajit-5.1.so'.
            koopa_ln \
                "libluajit-${dict['llj_min_maj_ver']}.${dict['shared_ext']}.\
${dict['majver']}.${dict['minver']}.${dict['relver']}" \
                "libluajit-${dict['llj_min_maj_ver']}.${dict['shared_ext']}"
            # e.g. 'libluajit-5.1.so' to 'libluajit.so'.
            koopa_ln \
                "libluajit-${dict['llj_min_maj_ver']}.${dict['shared_ext']}" \
                "libluajit.${dict['shared_ext']}"
        fi
    )
    return 0
}
