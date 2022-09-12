#!/usr/bin/env bash

# FIXME Hitting this install error on macOS:
#
# BUILDVM   jit/vmdef.lua
#DYNLINK   libluajit.so
#ld: warning: -seg1addr not 16384 byte aligned, rounding up
#LINK      luajit
#Undefined symbols for architecture x86_64:
#  "__Unwind_DeleteException", referenced from:
#      _lj_err_unwind_dwarf in libluajit.a(lj_err.o)
#  "__Unwind_GetCFA", referenced from:
#      _lj_err_unwind_dwarf in libluajit.a(lj_err.o)
#  "__Unwind_RaiseException", referenced from:
#      _lj_err_throw in libluajit.a(lj_err.o)
#  "__Unwind_SetGR", referenced from:
#      _lj_err_unwind_dwarf in libluajit.a(lj_err.o)
#  "__Unwind_SetIP", referenced from:
#      _lj_err_unwind_dwarf in libluajit.a(lj_err.o)
#ld: symbol(s) not found for architecture x86_64
#clang: error: linker command failed with exit code 1 (use -v to see invocation)
#gmake[1]: *** [Makefile:712: luajit] Error 1
#gmake[1]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220909-154453-irEx7INYWY/LuaJIT-2.1.0-beta3/src'
#gmake: *** [Makefile:113: default] Error 2

main() {
    # """
    # Install LuaJIT.
    # @note Updated 2022-09-09.
    #
    # @seealso
    # - https://luajit.org/download.html
    # - https://luajit.org/install.html
    # """
    local app dict
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
        ['pkg_config']="$(koopa_locate_pkg_config)"
    )
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    declare -A dict=(
        ['name']='LuaJIT'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://luajit.org/download/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    if koopa_is_macos
    then
        dict['macos_version']="$(koopa_macos_os_version)"
        MACOSX_DEPLOYMENT_TARGET="${dict['macos_version']}"
        export MACOSX_DEPLOYMENT_TARGET
    fi
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
        koopa_ln \
            "libluajit-${dict['llj_min_maj_ver']}.a" \
            'libluajit.a'
        koopa_ln \
            "libluajit-${dict['llj_min_maj_ver']}.${dict['shared_ext']}" \
            "libluajit.${dict['shared_ext']}"
    )
    return 0
}
