#!/usr/bin/env bash

koopa::install_subversion() { # {{{1
    koopa:::install_app \
        --name='subversion' \
        "$@"
}

koopa:::install_subversion() { # {{{1
    # """
    # Install Subversion.
    # @note Updated 2021-05-26.
    #
    # Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
    # Utility (APRUTIL) library.
    #
    # @seealso
    # - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
    # - https://subversion.apache.org/download.cgi
    # - https://subversion.apache.org/source-code.html
    # """
    local brew_apr brew_apr_util brew_prefix conf_args file jobs make name
    local prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='subversion'
    conf_args=("--prefix=${prefix}")
    if koopa::is_linux
    then
        if koopa::is_fedora
        then
            koopa::ln --sudo '/usr/bin/apr-1-config' '/usr/bin/apr-config'
            koopa::ln --sudo '/usr/bin/apu-1-config' '/usr/bin/apu-config'
            koopa::add_to_pkg_config_path_start '/usr/lib64/pkgconfig'
        fi
        koopa::assert_is_installed 'apr-config' 'apu-config' 'sqlite3'
        conf_args+=(
            '--with-lz4=internal'
            '--with-utf8proc=internal'
        )
    elif koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        brew_apr="${brew_prefix}/opt/apr"
        brew_apr_util="${brew_prefix}/opt/apr-util"
        koopa::assert_is_dir "$brew_prefix" "$brew_apr" "$brew_apr_util"
        conf_args+=(
            "--with-apr=${brew_apr}"
            "--with-apr-util=${brew_apr_util}"
        )
    fi
    file="${name}-${version}.tar.bz2"
    url="https://mirrors.ocf.berkeley.edu/apache/${name}/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}

koopa::uninstall_subversion() { # {{{1
    koopa:::uninstall_app \
        --name='subversion' \
        "$@"
}
