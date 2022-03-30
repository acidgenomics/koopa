#!/usr/bin/env bash

install_boost() { # {{{1
    # """
    # Install Boost library.
    # @note Updated 2022-03-29.
    #
    # @seealso
    # - https://www.boost.org/users/download/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/boost.rb
    # """
    local app b2_args bootstrap_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='boost'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[icu4c_prefix]="${dict[opt_prefix]}/icu4c"
    dict[snake_version]="$(koopa_snake_case_simple "${dict[version]}")"
    dict[file]="${dict[name]}_${dict[snake_version]}.tar.bz2"
    dict[url]="https://boostorg.jfrog.io/artifactory/main/release/\
${dict[version]}/source/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}_${dict[snake_version]}"
    bootstrap_args=(
        "--prefix=${dict[prefix]}"
        "--with-icu=${dict[icu4c_prefix]}"
        "--with-python=${app[python]}"
    )
    b2_args=(
        "--prefix=${dict[prefix]}"
        '-d2'
        "-j${dict[jobs]}"
        'install'
        'link=static'
        'threading=multi'
    )
    ./bootstrap.sh "${bootstrap_args[@]}"
    ./b2 headers
    ./b2 "${b2_args[@]}"
    return 0
}
