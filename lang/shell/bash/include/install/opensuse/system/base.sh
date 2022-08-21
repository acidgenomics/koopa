#!/usr/bin/env bash

main() {
    # """
    # Install openSUSE base system.
    # @note Updated 2022-07-18.
    #
    # zypper cheat sheet:
    # https://en.opensuse.org/images/1/17/Zypper-cheat-sheet-1.pdf
    # """
    local app pkgs
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['sudo']="$(koopa_locate_sudo)"
        ['zypper']="$(koopa_locate_zypper)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['zypper']}" ]] || return 1
    pkgs=(
        # > 'R-base'
        # > 'R-base-devel'
        # > 'texlive'
        'autoconf'
        'bc'
        'bzip2'
        'cmake'
        'curl'
        'gcc'
        'gcc-c++'
        'gcc-fortran'
        'gettext'
        'gettext-devel'
        'git'
        'glibc-i18ndata'
        'gmp-devel'
        'gzip'
        'libbz2-devel'
        'libcurl-devel'
        'libevent-devel'
        'libffi-devel'
        'libxml2-devel'
        # > 'lzma-devel'
        'make'
        'man'
        'mpc-devel'
        'mpfr-devel'
        'ncurses-devel'
        'openssl-devel'
        'pcre2-devel'
        'procps' # ps
        'readline-devel'
        'sudo'
        'tar'
        'texinfo'
        'tree'
        'unzip'
        'wget'
        'which'
        'xz'
        'zlib-devel'
        'zsh'
    )
    "${app['sudo']}" "${app['zypper']}" refresh
    "${app['sudo']}" "${app['zypper']}" --non-interactive update
    "${app['sudo']}" "${app['zypper']}" install -y "${pkgs[@]}"
    "${app['sudo']}" "${app['zypper']}" clean
    return 0
}

