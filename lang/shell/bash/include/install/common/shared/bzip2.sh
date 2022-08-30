#!/usr/bin/env bash

main() {
    # """
    # Install bzip2.
    # @note Updated 2022-08-30.
    #
    # @seealso
    # - https://www.sourceware.org/bzip2/
    # - https://gitlab.com/federicomenaquintero/bzip2
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
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cat']="$(koopa_locate_cat)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='bzip2'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://sourceware.org/pub/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['makefile_shared']="Makefile-libbz2_${dict['shared_ext']}"
    # NOTE The macOS dylib Makefile is a work in progress. Refer to MacPorts
    # recipe for an alternative approach. Note that Homebrew doesn't currently
    # bundle dylib file.
    # > if koopa_is_macos
    # > then
    # >     "${app['cat']}" > "${dict['makefile_shared']}" << END
# > PKG_VERSION=${dict['version']}
# >
# > SHELL=/bin/sh
# > CC=gcc
# > BIGFILES=-D_FILE_OFFSET_BITS=64
# > CFLAGS=-fpic -fPIC -Wall -Winline -O2 -g \$(BIGFILES)
# >
# > OBJS= blocksort.o  \
# > 	  huffman.o    \
# > 	  crctable.o   \
# > 	  randtable.o  \
# > 	  compress.o   \
# > 	  decompress.o \
# > 	  bzlib.o
# >
# > all: \$(OBJS)
# > 	\$(CC) -shared -Wl,-install_name -Wl,libbz2.dylib -o libbz2.\${PKG_VERSION}.dylib \$(OBJS)
# >
# > clean:
# > 	rm -f libbz2.dylib libbz2.\${PKG_VERSION}.dylib
# >
# > blocksort.o: blocksort.c
# > 	\$(CC) \$(CFLAGS) -c blocksort.c
# > huffman.o: huffman.c
# > 	\$(CC) \$(CFLAGS) -c huffman.c
# > crctable.o: crctable.c
# > 	\$(CC) \$(CFLAGS) -c crctable.c
# > randtable.o: randtable.c
# > 	\$(CC) \$(CFLAGS) -c randtable.c
# > compress.o: compress.c
# > 	\$(CC) \$(CFLAGS) -c compress.c
# > decompress.o: decompress.c
# > 	\$(CC) \$(CFLAGS) -c decompress.c
# > bzlib.o: bzlib.c
# > 	\$(CC) \$(CFLAGS) -c bzlib.c
# > END
    # > fi
    "${app['make']}" install "PREFIX=${dict['prefix']}"
    if [[ -f "${dict['makefile_shared']}" ]]
    then
        dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
        "${app['make']}" -f "${dict['makefile_shared']}" 'clean'
        "${app['make']}" -f "${dict['makefile_shared']}"
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
        fi
        # > elif koopa_is_macos
        # > then
        # >     koopa_cp \
        # >         --target-directory="${dict['prefix']}/lib" \
        # >         "libbz2.${dict['version']}.${dict['shared_ext']}"
        # >     (
        # >         koopa_cd "${dict['prefix']}/lib"
        # >         koopa_ln \
        # >             "libbz2.${dict['version']}.${dict['shared_ext']}" \
        # >             "libbz2.${dict['maj_min_ver']}.${dict['shared_ext']}"
        # >         koopa_ln \
        # >             "libbz2.${dict['version']}.${dict['shared_ext']}" \
        # >             "libbz2.${dict['shared_ext']}"
        # >     )
        # > fi
    fi
    return 0
}
