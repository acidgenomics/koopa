#!/usr/bin/env bash

main() {
    # """
    # Install p7zip.
    # @note Updated 2023-10-11.
    #
    # @seealso
    # - https://github.com/conda-forge/p7zip-feedstock
    # - https://formulae.brew.sh/formula/p7zip
    # - https://ports.macports.org/port/p7zip/
    # """
    local -A app dict
    app['cc']="$(koopa_locate_cc --only-system)"
    app['cxx']="$(koopa_locate_cxx --only-system)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/p7zip-project/p7zip/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    if koopa_is_linux
    then
        dict['makefile']='makefile.linux_any_cpu'
    elif koopa_is_macos
    then
        dict['makefile']='makefile.macosx_llvm_64bits'
    fi
    koopa_assert_is_file "${dict['makefile']}"
    koopa_ln "${dict['makefile']}" 'makefile.machine'
    CC="${app['cc']}"
    CXX="${app['cxx']}"
    export CC CXX
    koopa_print_env
    # The 'all3' here refers to '7z', '7za', and '7zr'.
    "${app['make']}" all3 \
        ALLFLAGS_C="${CFLAGS:-}" \
        ALLFLAGS_CPP="${CXXFLAGS:-}" \
        CC="${CC:-}" \
        CXX="${CXX:-}" \
        LDFLAGS="${LDFLAGS:-}"
    # Can also set 'DEST_SHARE_DOC', 'DEST_DIR' here if necessary. Refer to
    # MacPorts recipe for example.
    "${app['make']}" \
        DEST_HOME="${dict['prefix']}" \
        DEST_MAN="${dict['prefix']}/share/man" \
        install
    return 0
}
