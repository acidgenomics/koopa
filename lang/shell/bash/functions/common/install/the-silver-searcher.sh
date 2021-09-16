#!/usr/bin/env bash

koopa::install_the_silver_searcher() { # {{{1
    koopa:::install_app \
        --name='the-silver-searcher' \
        "$@"
}

koopa:::install_the_silver_searcher() { # {{{1
    # """
    # Install the silver searcher.
    # @note Updated 2021-05-26.
    #
    # Ag has been renamed to The Silver Searcher.
    #
    # Current tagged release hasn't been updated in a while and has a lot of 
    # bug fixes on GitHub, including GCC 10 support, which is required for
    # Fedora 32.
    #
    # GPG signed releases:
    # > file="${name2}-${version}.tar.gz"
    # > url="https://geoff.greer.fm/ag/releases/${file}"
    #
    # Tagged GitHub release.
    # > file="${version}.tar.gz"
    # > url="https://github.com/ggreer/${name2}/archive/${file}"
    #
    # Note that Fedora has changed pkg-config to pkgconf, which is causing
    # issues with ag building from source. Install the regular pkg-config from
    # source to fix this build issue.
    # https://fedoraproject.org/wiki/Changes/
    #     pkgconf_as_system_pkg-config_implementation
    # In this case, you'll see this error:
    # # ./configure: [...] syntax error near unexpected token `PCRE,'
    # # ./configure: [...] `PKG_CHECK_MODULES(PCRE, libpcre)'
    # https://github.com/ggreer/the_silver_searcher/issues/341
    # """
    local file jobs make name name2 prefix url version
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'pcre' 'pkg-config'
    fi
    koopa::assert_is_installed 'pcre-config' 'pkg-config'
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='the-silver-searcher'
    # Temporarily installing from master branch, which has bug fixes that aren't
    # yet available in tagged release, especially for GCC 10.
    version='master'
    name2="$(koopa::snake_case_simple "$name")"
    file="${version}.tar.gz"
    url="https://github.com/ggreer/${name2}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    # Refer to 'build.sh' script for details.
    ./autogen.sh
    ./configure --prefix="$prefix"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}

koopa::uninstall_the_silver_searcher() { # {{{1
    koopa:::uninstall_app \
        --name='the-silver-searcher' \
        "$@"
}
