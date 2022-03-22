#!/usr/bin/env bash

install_cmake() { # {{{1
    # """
    # Install CMake.
    # @note Updated 2021-11-24.
    #
    # @seealso
    # - https://github.com/Kitware/CMake
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='cmake'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/Kitware/CMake/releases/download/\
v${dict[version]}/${dict[file]}"
    if koopa_is_linux
    then
        app[cc]='/usr/bin/gcc'
        app[cxx]='/usr/bin/g++'
        koopa_assert_is_installed "${app[cc]}" "${app[cxx]}"
        export CC="${app[cc]}"
        export CXX="${app[cxx]}"
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # Note that the './configure' script is just a wrapper for './bootstrap'.
    # > ./bootstrap --help
    ./bootstrap \
        --parallel="${dict[jobs]}" \
        --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
