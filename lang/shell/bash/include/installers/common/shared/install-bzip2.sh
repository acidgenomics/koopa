#!/usr/bin/env bash

# FIXME We need to rework our shared object build approach here.

main() {
    # """
    # Install bzip2.
    # @note Updated 2022-08-12.
    #
    # @seealso
    # - https://www.sourceware.org/bzip2/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bzip2.rb
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
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='bzip2'
        [prefix]="${INSTALL_PREFIX:?}"
        [shared_ext]="$(koopa_shared_ext)"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://sourceware.org/pub/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[make]}" install "PREFIX=${dict[prefix]}"
    if koopa_is_linux
    then
        dict[makefile_shared]='Makefile-libbz2_so'
    elif koopa_is_macos
    then
        dict[makefile_shared]='Makefile-libbz2_dylib'
        "${app[cat]}" > "${dict[makefile_shared]}" << END
# This Makefile builds a shared version of the library,
# libbz2.dylib for MacOSX x86 (10.13.4 or higher),
# with gcc-2.96 20000731 (Red Hat Linux 7.1 2.96-98).
# It is a custom Makefile. Use at own risk.
# Run in your MacOS terminal with the following command:
# make -f Makefile-libbz2_dylib

PKG_VERSION?=1.0.8
PREFIX?=/usr/local

SHELL=/bin/sh
CC=gcc
BIGFILES=-D_FILE_OFFSET_BITS=64
CFLAGS=-fpic -fPIC -Wall -Winline -O2 -g $(BIGFILES)

OBJS= blocksort.o  \
	  huffman.o    \
	  crctable.o   \
	  randtable.o  \
	  compress.o   \
	  decompress.o \
	  bzlib.o

all: $(OBJS)
	$(CC) -shared -Wl,-install_name -Wl,libbz2.dylib -o libbz2.${PKG_VERSION}.dylib $(OBJS)
	cp libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/
	ln -s libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/libbz2.dylib

clean:
	rm -f libbz2.dylib libbz2.${PKG_VERSION}.dylib

blocksort.o: blocksort.c
	$(CC) $(CFLAGS) -c blocksort.c
huffman.o: huffman.c
	$(CC) $(CFLAGS) -c huffman.c
crctable.o: crctable.c
	$(CC) $(CFLAGS) -c crctable.c
randtable.o: randtable.c
	$(CC) $(CFLAGS) -c randtable.c
compress.o: compress.c
	$(CC) $(CFLAGS) -c compress.c
decompress.o: decompress.c
	$(CC) $(CFLAGS) -c decompress.c
bzlib.o: bzlib.c
	$(CC) $(CFLAGS) -c bzlib.c
END
    fi
    "${app[make]}" -f "${dict[makefile_shared]}" 'clean'
    "${app[make]}" -f "${dict[makefile_shared]}"
    koopa_cp \
        --target-directory="${dict[prefix]}/lib" \
        "libbz2.${dict[shared_ext]}.${dict[version]}"
    (
        koopa_cd "${dict[prefix]}/lib"
        koopa_ln \
            "libbz2.${dict[shared_ext]}.${dict[version]}" \
            "libbz2.${dict[shared_ext]}.${dict[maj_min_ver]}"
        koopa_ln \
            "libbz2.${dict[shared_ext]}.${dict[version]}" \
            "libbz2.${dict[shared_ext]}"
    )
    return 0
}
