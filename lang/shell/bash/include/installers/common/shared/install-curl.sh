#!/usr/bin/env bash

main() {
    # """
    # Install cURL.
    # @note Updated 2022-04-22.
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
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix 'openssl'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='curl'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[version2]="${dict[version]//./_}"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/releases/\
download/${dict[name]}-${dict[version2]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-versioned-symbols'
        '--with-openssl'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
