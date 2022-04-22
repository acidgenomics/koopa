#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install ICU4C.
    # @note Updated 2022-04-12.
    #
    # @seealso
    # - https://unicode-org.github.io/icu/userguide/icu4c/build.html
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
        [name]='icu4c'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[kebab_version]="$(koopa_kebab_case_simple "${dict[version]}")"
    dict[snake_version]="$(koopa_snake_case_simple "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[snake_version]}-src.tgz"
    dict[url]="https://github.com/unicode-org/icu/releases/download/\
release-${dict[kebab_version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd 'icu/source'
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-samples'
        '--disable-tests'
        '--enable-rpath'
        '--enable-shared'
        '--enable-static'
        '--with-library-bits=64'
    )
    koopa_add_rpath_to_ldflags "${dict[prefix]}/lib"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    # Can check configuration success with:
    # > app[icuinfo]="${dict[prefix]}/bin/icuinfo"
    # > koopa_assert_is_installed "${app[icuinfo]}"
    # > "${app[icuinfo]}"
    return 0
}
