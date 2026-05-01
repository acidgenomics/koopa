#!/usr/bin/env bash

# FIXME Rework by creating a Makefile instead.

main() {
    # """
    # Install bzip2.
    # @note Updated 2023-10-17.
    #
    # @seealso
    # - https://www.sourceware.org/bzip2/
    # - https://github.com/apple-open-source/macos/tree/master/bzip2/bzip2
    # - https://github.com/conda-forge/bzip2-feedstock/blob/main/recipe/build.sh
    # - https://opensource.apple.com/source/bzip2/bzip2-16.5/bzip2/
    #     Makefile.auto.html
    # - https://gitlab.com/bzip2/bzip2
    # - https://gitlab.com/federicomenaquintero/bzip2
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bzip2.rb
    # - https://github.com/macports/macports-ports/blob/master/archivers/
    #     bzip2/Portfile
    # - https://stackoverflow.com/questions/67179779/
    # - https://gist.githubusercontent.com/obihill/
    #     3278c17bcee41c0c8b59a41ada8c0d35/raw/
    #     3bf890e2ad40d0af358e153395c228326f0b44d5/Makefile-libbz2_dylib
    # - https://mjtsai.com/blog/2020/06/26/reverse-engineering-macos-11-0/
    # """
    local -A app dict
    _koopa_activate_app --build-only 'make'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    _koopa_mkdir "${dict['prefix']}/lib"
    dict['url']="https://sourceware.org/pub/bzip2/\
bzip2-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    dict['maj_min_ver']="$(_koopa_major_minor_version "${dict['version']}")"
    dict['makefile_shared']="Makefile-libbz2_${dict['shared_ext']}"
    # Create missing dylib Makefile for macOS.
    # https://gist.github.com/obihill/3278c17bcee41c0c8b59a41ada8c0d35
    if [[ ! -f "${dict['makefile_shared']}" ]] && _koopa_is_macos
    then
        _koopa_alert "Adding '${dict['makefile_shared']}'."
        read -r -d '' "dict[makefile_string]" << END || true
PKG_VERSION?=${dict['version']}
PREFIX?=${dict['prefix']}

SHELL=/bin/sh
CC=gcc
BIGFILES=-D_FILE_OFFSET_BITS=64
CFLAGS=-fpic -fPIC -Wall -Winline -O2 -g \$(BIGFILES)

OBJS= blocksort.o  \
	  huffman.o    \
	  crctable.o   \
	  randtable.o  \
	  compress.o   \
	  decompress.o \
	  bzlib.o

all: \$(OBJS)
	\$(CC) -shared -Wl,-install_name -Wl,libbz2.dylib -o libbz2.\${PKG_VERSION}.dylib \$(OBJS)
	cp libbz2.\${PKG_VERSION}.dylib \${PREFIX}/lib/
	ln -s libbz2.\${PKG_VERSION}.dylib \${PREFIX}/lib/libbz2.dylib

clean:
	rm -f libbz2.dylib libbz2.\${PKG_VERSION}.dylib

blocksort.o: blocksort.c
	\$(CC) \$(CFLAGS) -c blocksort.c
huffman.o: huffman.c
	\$(CC) \$(CFLAGS) -c huffman.c
crctable.o: crctable.c
	\$(CC) \$(CFLAGS) -c crctable.c
randtable.o: randtable.c
	\$(CC) \$(CFLAGS) -c randtable.c
compress.o: compress.c
	\$(CC) \$(CFLAGS) -c compress.c
decompress.o: decompress.c
	\$(CC) \$(CFLAGS) -c decompress.c
bzlib.o: bzlib.c
	\$(CC) \$(CFLAGS) -c bzlib.c
END
        _koopa_write_string \
            --file="${dict['makefile_shared']}" \
            --string="${dict['makefile_string']}"
    fi
    _koopa_print_env
    "${app['make']}" install "PREFIX=${dict['prefix']}"
    if [[ -f "${dict['makefile_shared']}" ]]
    then
        "${app['make']}" -f "${dict['makefile_shared']}" 'clean'
        "${app['make']}" -f "${dict['makefile_shared']}"
    fi
    if _koopa_is_linux
    then
        _koopa_cp \
            --target-directory="${dict['prefix']}/lib" \
            "libbz2.${dict['shared_ext']}.${dict['version']}"
        (
            _koopa_cd "${dict['prefix']}/lib"
            _koopa_ln \
                "libbz2.${dict['shared_ext']}.${dict['version']}" \
                "libbz2.${dict['shared_ext']}.${dict['maj_min_ver']}"
            _koopa_ln \
                "libbz2.${dict['shared_ext']}.${dict['version']}" \
                "libbz2.${dict['shared_ext']}"
        )
    elif _koopa_is_macos
    then
        _koopa_cp \
            --target-directory="${dict['prefix']}/lib" \
            "libbz2.${dict['version']}.${dict['shared_ext']}"
        (
            _koopa_cd "${dict['prefix']}/lib"
            _koopa_ln \
                "libbz2.${dict['version']}.${dict['shared_ext']}" \
                "libbz2.${dict['maj_min_ver']}.${dict['shared_ext']}"
            _koopa_ln \
                "libbz2.${dict['version']}.${dict['shared_ext']}" \
                "libbz2.${dict['shared_ext']}"
        )
    fi
    # Remove the unwanted static file.
    _koopa_rm "${dict['prefix']}/lib/"*'.a'
    # Create pkg-config file, if necessary.
    dict['pkg_config_file']="${dict['prefix']}/lib/pkgconfig/bzip2.pc"
    if [[ ! -f "${dict['pkg_config_file']}" ]]
    then
        _koopa_alert 'Adding pkg-config support.'
        read -r -d '' "dict[pkg_config_string]" << END || true
prefix=${dict['prefix']}
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: bzip2
Description: Lossless, block-sorting data compression
Version: ${dict['version']}
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
END
        _koopa_write_string \
            --file="${dict['pkg_config_file']}" \
            --string="${dict['pkg_config_string']}"
    fi
    return 0
}
