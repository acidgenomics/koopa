#!/usr/bin/env bash

# NOTE Details regarding broken LICENSE file in 74.2 update:
# - https://github.com/unicode-org/icu/pull/2749#issuecomment-1858570143
# - https://github.com/Homebrew/homebrew-core/pull/153108
# NOTE Need to error here if user is attempting to compile with GCC 4.
# NOTE 76 release series doesn't build libxml2 currently.

main() {
    # """
    # Install ICU4C.
    # @note Updated 2024-12-30.
    #
    # @seealso
    # - https://unicode-org.github.io/icu/userguide/icu4c/build.html
    # - https://github.com/unicode-org/icu/
    # - https://github.com/conda-forge/icu-feedstock/
    # - https://formulae.brew.sh/formula/icu4c@76
    # - https://formulae.brew.sh/formula/icu4c@75
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['kebab_version']="$(koopa_kebab_case "${dict['version']}")"
    dict['snake_version']="$(koopa_snake_case "${dict['version']}")"
    conf_args+=(
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
    # This step can error due to broken 'LICENSE' symlink in 74.2.
    koopa_extract "$(koopa_basename "${dict['url']}")" 'icu'
    # Broken LICENSE symlink causes make to fail.
    if [[ ! -e 'icu/LICENSE' ]]
    then
        koopa_rm 'icu/LICENSE'
        koopa_touch 'icu/LICENSE'
    fi
    koopa_cd 'icu/source'
    koopa_add_rpath_to_ldflags "${dict['prefix']}/lib"
    koopa_make_build "${conf_args[@]}"
    return 0
}
