#!/usr/bin/env bash

main() {
    # """
    # Install pbzip2.
    # @note Updated 2023-10-10.
    #
    # @seealso
    # - https://github.com/conda-forge/pbzip2-feedstock
    # - https://formulae.brew.sh/formula/pbzip2
    # """
    local -A app dict
    _koopa_activate_app --build-only 'make'
    ! _koopa_is_macos && _koopa_activate_app 'bzip2'
    app['cc']="$(_koopa_locate_cc --only-system)"
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(_koopa_major_minor_version "${dict['version']}")"
    dict['url']="https://launchpad.net/pbzip2/${dict['maj_min_ver']}/\
${dict['version']}/+download/pbzip2-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
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
