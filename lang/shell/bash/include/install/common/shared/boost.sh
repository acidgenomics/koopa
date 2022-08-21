#!/usr/bin/env bash

main() {
    # """
    # Install Boost library.
    # @note Updated 2022-08-11.
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
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='boost'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[snake_version]="$(koopa_snake_case_simple "${dict['version']}")"
    dict[file]="${dict['name']}_${dict['snake_version']}.tar.bz2"
    dict[url]="https://boostorg.jfrog.io/artifactory/main/release/\
${dict['version']}/source/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}_${dict['snake_version']}"
    dict[icu4c]="$(koopa_app_prefix 'icu4c')"
    bootstrap_args=(
        "--prefix=${dict['prefix']}"
        "--with-icu=${dict['icu4c']}"
        "--with-python=${app['python']}"
    )
    b2_args=(
        "--prefix=${dict['prefix']}"
        '-d2'
        "-j${dict['jobs']}"
        'install'
        'link=static'
        'threading=multi'
    )
    koopa_alert_coffee_time
    ./bootstrap.sh "${bootstrap_args[@]}"
    ./b2 headers
    ./b2 "${b2_args[@]}"
    return 0
}
