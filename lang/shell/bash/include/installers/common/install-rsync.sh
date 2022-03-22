#!/usr/bin/env bash

install_rsync() { # {{{1
    # """
    # Install rsync.
    # @note Updated 2022-01-06.
    #
    # @seealso
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='rsync'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://download.samba.org/pub/${dict[name]}/src/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=("--prefix=${dict[prefix]}")
    if koopa_is_macos
    then
        # Even though Homebrew provides OpenSSL, hard to link.
        conf_args+=('--disable-openssl')
    elif koopa_is_linux
    then
        conf_args+=(
            # > '--without-included-zlib'
            '--disable-zstd'
        )
        if koopa_is_rhel_like
        then
            conf_args+=('--disable-xxhash')
        fi
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
