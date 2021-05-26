#!/usr/bin/env bash

koopa::install_proj() { # {{{1
    koopa::install_app \
        --name='proj' \
        --name-fancy='PROJ' \
        --no-link \
        "$@"
}

koopa:::install_proj() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2021-05-26.
    # """
    local arch conf_args file make_prefix prefix url version
    koopa::assert_is_installed sqlite3
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    arch="$(koopa::arch)"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='proj'
    conf_args=("--prefix=${prefix}")
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix pkg-config libtiff sqlite3
    elif koopa_is_linux
    then
        make_prefix="$(koopa::make_prefix)"
        conf_args+=(
            "CFLAGS=-I${make_prefix}/include"
            "LDFLAGS=-L${make_prefix}/lib"
        )
        # Ensure we're using our custom build of SQLite, in '/usr/local'.
        SQLITE3_CFLAGS="-I${make_prefix}/include"
        SQLITE3_LIBS="-L${make_prefix}/lib -lsqlite3"
        # Fix needed to avoid libtiff-4 detection failure.
        # Alternatively, can set '--disable-tiff' configure flag.
        if koopa::is_debian_like
        then
            # pkg-config: /usr/lib/x86_64-linux-gnu/pkgconfig/libtiff-4.pc
            TIFF_CFLAGS="/usr/include/${arch}-linux-gnu"
            TIFF_LIBS="/usr/lib/${arch}-linux-gnu -ltiff"
        elif koopa::is_fedora_like
        then
            # pkg-config: /usr/lib64/pkgconfig/libtiff-4.pc
            TIFF_CFLAGS='/usr/include'
            TIFF_LIBS='/usr/lib64 -ltiff'
        fi
        export SQLITE3_CFLAGS SQLITE3_LIBS TIFF_CFLAGS TIFF_LIBS
    fi
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/PROJ/releases/download/${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}
