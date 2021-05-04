#!/usr/bin/env bash

install_cpufetch() { # {{{1
    # """
    # Install cpufetch.
    # @note Updated 2021-05-04.
    #
    # NOTE v0.94 stable release fails to compile on macOS.
    # use of undeclared identifier 'cpu_set_t'
    # https://github.com/Dr-Noob/cpufetch/issues/38
    # """
    local file jobs name prefix url version
    koopa::assert_is_installed git make
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='cpufetch'
    jobs="$(koopa::cpu_count)"
    case "$version" in
        0.96)
            # No stable release for this yet, use master branch.
            git clone "https://github.com/Dr-Noob/${name}.git"
            koopa::cd "$name"
            ;;
        *)
            file="v${version}.tar.gz"
            url="https://github.com/Dr-Noob/${name}/archive/refs/tags/${file}"
            koopa::download "$url"
            koopa::extract "$file"
            koopa::cd "${name}-${version}"
            ;;
    esac
    # Installer doesn't currently support 'configure' script.
    PREFIX="$prefix" make --jobs="$jobs"
    PREFIX="$prefix" make install
    return 0
}

install_cpufetch "$@"
