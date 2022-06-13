#!/usr/bin/env bash

# NOTE Switch 'jpeg' to 'libjpeg-turbo'?

main() {
    # """
    # Install libgeotiff.
    # @note Updated 2022-06-13.
    #
    # @seealso
    # - https://github.com/OSGeo/libgeotiff
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     libgeotiff.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'libtool' 'pkg-config'
    koopa_activate_opt_prefix \
        'curl' \
        'jpeg' \
        'libtiff' \
        'sqlite' \
        'proj'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libgeotiff'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/${dict[name]}/releases/download/\
${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        '--disable-dependency-tracking'
        "--prefix=${dict[prefix]}"
        '--with-jpeg'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
