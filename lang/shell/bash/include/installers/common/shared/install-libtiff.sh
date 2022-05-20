#!/usr/bin/env bash

# Switch to libjpeg-turbo?

main() {
    # """
    # Install libtiff.
    # @note Updated 2022-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libtiff.rb
    # - https://gitlab.com/libtiff/libtiff/-/commit/
    #     b25618f6fcaf5b39f0a5b6be3ab2fb288cf7a75b
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libtiff.html
    # - https://github.com/opentoonz/opentoonz/issues/1566
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'libjpeg-turbo' 'zstd'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="tiff-${dict[version]}.tar.gz"
    dict[url]="http://download.osgeo.org/libtiff/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "tiff-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--disable-lzma'
        '--disable-webp'
        '--enable-shared=yes'
        '--enable-static=yes'
        '--without-x'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
