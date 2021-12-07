#!/usr/bin/env bash

# NOTE Now seeing this warning on Debian:
# g++: warning: /usr/include/x86_64-linux-gnu: linker input file unused
# because linking not done

koopa:::install_proj() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2021-11-24.
    # """
    local app conf_args dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [jobs]="$(koopa::cpu_count)"
        [make_prefix]="$(koopa::make_prefix)"
        [name]='proj'
        [os]='linux-gnu'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=("--prefix=${dict[prefix]}")
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'pkg-config' 'libtiff' 'sqlite3'
    elif koopa::is_linux
    then
        conf_args+=(
            "CFLAGS=-I${dict[make_prefix]}/include"
            "LDFLAGS=-L${dict[make_prefix]}/lib"
        )
        # Ensure we're using our custom build of SQLite, in '/usr/local'.
        SQLITE3_CFLAGS="-I${dict[make_prefix]}/include"
        SQLITE3_LIBS="-L${dict[make_prefix]}/lib -lsqlite3"
        # Fix needed to avoid libtiff-4 detection failure.
        # Alternatively, can set '--disable-tiff' configure flag.
        if koopa::is_debian_like
        then
            # pkg-config: '/usr/lib/x86_64-linux-gnu/pkgconfig/libtiff-4.pc'.
            TIFF_CFLAGS="/usr/include/${dict[arch]}-${dict[os]}"
            TIFF_LIBS="/usr/lib/${dict[arch]}-${dict[os]} -ltiff"
        elif koopa::is_fedora_like
        then
            # pkg-config: '/usr/lib64/pkgconfig/libtiff-4.pc'.
            TIFF_CFLAGS='/usr/include'
            TIFF_LIBS='/usr/lib64 -ltiff'
        fi
        export SQLITE3_CFLAGS SQLITE3_LIBS TIFF_CFLAGS TIFF_LIBS
    fi
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/PROJ/releases/download/\
${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
