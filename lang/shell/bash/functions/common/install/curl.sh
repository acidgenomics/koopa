#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_curl() { # {{{1
    koopa::install_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa:::install_curl() { # {{{1
    # """
    # Install cURL.
    # @note Updated 2021-05-27.
    #
    # The '--enable-versioned-symbols' avoids issue with curl installed in
    # both '/usr' and '/usr/local'.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/curl.rb
    # - https://curl.haxx.se/docs/install.html
    # - https://stackoverflow.com/questions/30017397
    # """
    local conf_args file jobs make name prefix url version version2
    # > if koopa::is_macos
    # > then
    # >     koopa::activate_homebrew_opt_prefix 'openssl@1.1'
    # > fi
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='curl'
    file="${name}-${version}.tar.xz"
    version2="${version//./_}"
    url="https://github.com/${name}/${name}/releases/download/\
${name}-${version2}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    conf_args=(
        "--prefix=${prefix}"
        '--enable-versioned-symbols'
    )
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        conf_args+=(
            "--with-ssl=${brew_prefix}/opt/openssl@1.1"
        )
    fi
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" test
    "$make" install
    return 0
}

koopa::uninstall_curl() { # {{{1
    koopa::uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}
