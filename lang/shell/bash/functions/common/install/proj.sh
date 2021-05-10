#!/usr/bin/env bash

# FIXME Need to rethink this for macOS...

koopa::install_proj() { # {{{1
    koopa::install_app \
        --name='proj' \
        --name-fancy='PROJ' \
        "$@"
}

koopa:::install_proj() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2021-05-10.
    # """
    local arch brew_prefix conf_args file make_prefix prefix url version
    koopa::assert_is_installed sqlite3
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='proj'
    arch="$(koopa::arch)"
    jobs="$(koopa::cpu_count)"
    conf_args=("--prefix=${prefix}")
    if koopa::is_macos
    then
        # FIXME DO WE NEED TO SET MORE VALUES IN THE SHELL?
        brew_prefix="$(koopa::homebrew_prefix)"
        # FIXME This needs to activate pkg-config path correctly...
        koopa::activate_homebrew_opt_prefix libtiff sqlite3
        # FIXME Add sqlite to these variables.
        # Set TIFF variables.
        # FIXME This isn't picking up sqlite3 in pkg-config.
        # need to echo the value here?
        echo "${PKG_CONFIG_PATH:-}"
        koopa::stop 'FIXME'
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
        # FIXME Do these values persist in the shell session after install?
        export SQLITE3_CFLAGS SQLITE3_LIBS TIFF_CFLAGS TIFF_LIBS
    fi
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/PROJ/releases/download/${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure "${conf_args[@]}"
    make --jobs="$jobs"
    make install
    return 0
}
