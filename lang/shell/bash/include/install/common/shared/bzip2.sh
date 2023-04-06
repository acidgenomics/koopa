#!/usr/bin/env bash

main() {
    # """
    # Install bzip2.
    # @note Updated 2023-03-27.
    #
    # @seealso
    # - https://www.sourceware.org/bzip2/
    # - https://gitlab.com/federicomenaquintero/bzip2
    # - https://github.com/conda-forge/bzip2-feedstock/blob/main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bzip2.rb
    # - https://github.com/macports/macports-ports/blob/master/archivers/
    #     bzip2/Portfile
    # - https://stackoverflow.com/questions/67179779/
    # - https://opensource.apple.com/source/bzip2/bzip2-16.5/bzip2/
    #     Makefile.auto.html
    # - https://gist.githubusercontent.com/obihill/
    #     3278c17bcee41c0c8b59a41ada8c0d35/raw/
    #     3bf890e2ad40d0af358e153395c228326f0b44d5/Makefile-libbz2_dylib
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='bzip2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://sourceware.org/pub/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['makefile_shared']="Makefile-libbz2_${dict['shared_ext']}"
    koopa_print_env
    "${app['make']}" install "PREFIX=${dict['prefix']}"
    if [[ -f "${dict['makefile_shared']}" ]]
    then
        "${app['make']}" -f "${dict['makefile_shared']}" 'clean'
        "${app['make']}" -f "${dict['makefile_shared']}"
    elif koopa_is_macos
    then
        # This is the approach used by conda-forge recipe.
        app['cc']='gcc'
        "${app['cc']}" \
            '-shared' \
            '-Wl,-install_name' \
            "-Wl,libbz2.${dict['shared_ext']}" \
            -o "libbz2.${dict['version']}.${dict['shared_ext']}" \
            'blocksort.o' \
            'huffman.o' \
            'crctable.o' \
            'randtable.o' \
            'compress.o' \
            'decompress.o' \
            'bzlib.o'
            # > "${LDFLAGS:-}"
    fi
    if koopa_is_linux
    then
        koopa_cp \
            --target-directory="${dict['prefix']}/lib" \
            "libbz2.${dict['shared_ext']}.${dict['version']}"
        (
            koopa_cd "${dict['prefix']}/lib"
            koopa_ln \
                "libbz2.${dict['shared_ext']}.${dict['version']}" \
                "libbz2.${dict['shared_ext']}.${dict['maj_min_ver']}"
            koopa_ln \
                "libbz2.${dict['shared_ext']}.${dict['version']}" \
                "libbz2.${dict['shared_ext']}"
        )
    elif koopa_is_macos
    then
        koopa_cp \
            --target-directory="${dict['prefix']}/lib" \
            "libbz2.${dict['version']}.${dict['shared_ext']}"
        (
            koopa_cd "${dict['prefix']}/lib"
            koopa_ln \
                "libbz2.${dict['version']}.${dict['shared_ext']}" \
                "libbz2.${dict['maj_min_ver']}.${dict['shared_ext']}"
            koopa_ln \
                "libbz2.${dict['version']}.${dict['shared_ext']}" \
                "libbz2.${dict['shared_ext']}"
        )
    fi
    return 0
}
