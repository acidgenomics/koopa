#!/usr/bin/env bash

# Consider requiring: liblzma, zstd, and xz?.

main() { # {{{
    # """
    # Install libzip.
    # @note Updated 2022-04-11.
    #
    # @seealso
    # - https://libzip.org/download/
    # - https://noknow.info/it/os/install_libzip_from_source?lang=en
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'cmake' \
        'perl' \
        'pkg-config' \
        'zstd'
    koopa_is_macos && koopa_activate_opt_prefix 'openssl'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libzip'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://libzip.org/download/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    "${app[cmake]}" .. \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
