#!/usr/bin/env bash

koopa:::install_curl() { # {{{1
    # """
    # Install cURL.
    # @note Updated 2021-11-30.
    #
    # The '--enable-versioned-symbols' avoids issue with curl installed in
    # both '/usr' and '/usr/local'.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/curl.rb
    # - https://curl.haxx.se/docs/install.html
    # - https://stackoverflow.com/questions/30017397
    # """
    local app dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='curl'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[version2]="${dict[version]//./_}"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/releases/\
download/${dict[name]}-${dict[version2]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-versioned-symbols'
    )
    if koopa::is_macos
    then
        dict[brew_prefix]="$(koopa::homebrew_prefix)"
        conf_args+=(
            "--with-ssl=${dict[brew_prefix]}/opt/openssl@1.1"
        )
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
