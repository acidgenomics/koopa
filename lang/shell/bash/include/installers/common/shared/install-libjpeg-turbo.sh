#!/usr/bin/env bash

# NOTE Add support for NASM compiler, to improve performance.

main() { # {{{1
    # """
    # Install libjpeg-turbo.
    # @note Updated 2022-04-20.
    #
    # @seealso
    # - https://libjpeg-turbo.org/
    # - https://github.com/libjpeg-turbo/libjpeg-turbo/blob/main/BUILDING.md
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     jpeg-turbo.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libjpeg-turbo'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://downloads.sourceforge.net/project/${dict[name]}/\
${dict[version]}/${dict[name]}-${dict[version]}.tar.gz"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        '-DCMAKE_BUILD_TYPE=Release'
        '-DWITH_JPEG8=1'
    )
    "${app[cmake]}" '.' "${cmake_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
