#!/usr/bin/env bash

koopa::install_curl() { # {{{1
    koopa::install_app \
        --name='curl' \
        --name-fancy='cURL' \
        "$@"
}

koopa:::install_curl() { # {{{1
    # """
    # Install cURL.
    # @note Updated 2021-05-26.
    #
    # The '--enable-versioned-symbols' avoids issue with curl installed in
    # both '/usr' and '/usr/local'.
    #
    # @seealso
    # - https://curl.haxx.se/docs/install.html
    # - https://stackoverflow.com/questions/30017397
    # """
    local conf_args file jobs make name prefix url version version2
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
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" test
    "$make" install
    return 0
}
