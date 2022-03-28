#!/usr/bin/env bash

install_icu4c() { # {{{1
    # """
    # Install ICU4C.
    # @note Updated 2022-03-28.
    #
    # @seealso
    # - https://github.com/unicode-org/icu/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/icu4c.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[kebab_version]="$(koopa_kebab_case_simple "${dict[version]}")"
    dict[snake_version]="$(koopa_snake_case_simple "${dict[version]}")"
    dict[file]="icu4c-${dict[snake_version]}-src.tgz"
    dict[url]="https://github.com/unicode-org/icu/releases/download/\
release-${dict[kebab_version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd 'icu'
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-samples'
        '--disable-tests'
        '--enable-static'
        '--with-library-bits=64'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
