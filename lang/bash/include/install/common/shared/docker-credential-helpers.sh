#!/usr/bin/env bash

main() {
    # """
    # Install docker-credential-pass.
    # @note Updated 2023-05-14.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     docker-credential-helper.rb
    # """
    local -A app dict
    _koopa_activate_app --build-only 'go' 'make' 'pkg-config'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/docker/docker-credential-helpers/archive/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    if _koopa_is_macos
    then
        "${app['make']}" 'osxkeychain'
        _koopa_cp \
            --target-directory="${dict['prefix']}/bin" \
            'bin/build/docker-credential-osxkeychain'
    else
        "${app['make']}" 'pass'
        _koopa_cp \
            --target-directory="${dict['prefix']}/bin" \
            'bin/build/docker-credential-pass'
        # NOTE This requires 'libsecret' to be installed.
        # > "${app['make']}" 'secretservice'
        # > _koopa_cp \
        # >     --target-directory="${dict['prefix']}/bin" \
        # >     'bin/build/docker-credential-pass' \
        # >     'bin/build/docker-credential-secretservice'
    fi
    return 0
}
