#!/usr/bin/env bash

main() {
    # """
    # Install ICU4C.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://unicode-org.github.io/icu/userguide/icu4c/build.html
    # - https://github.com/unicode-org/icu/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/icu4c.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['kebab_version']="$(koopa_kebab_case "${dict['version']}")"
    dict['snake_version']="$(koopa_snake_case "${dict['version']}")"
    conf_args=(
        '--disable-samples'
        '--disable-static'
        '--disable-tests'
        '--enable-rpath'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
        '--with-library-bits=64'
    )
    dict['url']="https://github.com/unicode-org/icu/releases/download/\
release-${dict['kebab_version']}/icu4c-${dict['snake_version']}-src.tgz"
    koopa_download "${dict['url']}"
    # NOTE This step can error due to broken 'LICENSE' symlink.
    koopa_extract "$(koopa_basename "${dict['url']}")" 'icu'
    koopa_cd 'icu/source'
    koopa_add_rpath_to_ldflags "${dict['prefix']}/lib"
    koopa_make_build "${conf_args[@]}"
    return 0
}
