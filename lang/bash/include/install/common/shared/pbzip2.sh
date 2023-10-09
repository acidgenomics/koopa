#!/usr/bin/env bash

main() {
    # """
    # Install pbzip2.
    # @note Updated 2023-10-09.
    #
    # @seealso
    # - https://github.com/conda-forge/pbzip2-feedstock
    # - https://formulae.brew.sh/formula/pbzip2
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    # FIXME How to link our bzip2 correctly on macOS Sonoma?
    ! koopa_is_macos && koopa_activate_app 'bzip2'
    app['cc']="$(koopa_locate_cc)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['url']="https://launchpad.net/pbzip2/${dict['maj_min_ver']}/\
${dict['version']}/+download/pbzip2-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        CC="${app['cc']}" \
        CXXFLAGS="${CPPFLAGS:-}" \
        LDFLAGS="${LDFLAGS:-}" \
        PREFIX="${dict['prefix']}" \
        VERBOSE=1 \
        install
    return 0
}
