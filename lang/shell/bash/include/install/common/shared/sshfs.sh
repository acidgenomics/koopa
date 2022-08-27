#!/usr/bin/env bash

# FIXME This needs to depend on libfuse.

main() {
    # """
    # Install sshfs.
    # @note Updated 2022-08-27.
    #
    # @seealso
    # - https://github.com/libfuse/sshfs/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/sshfs.rb
    # """
    local app dict
    koopa_activate_build_opt_prefix \
        'cmake' \
        'meson' \
        'ninja' \
        'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'libffi' \
        'glib'
    declare -A app=(
        ['meson']="$(koopa_locate_meson)"
        ['ninja']="$(koopa_locate_ninja)"
    )
    declare -A dict=(
        ['name']="${INSTALL_NAME:?}"
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/libfuse/sshfs/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    "${app['meson']}" ..
    "${app['meson']}" configure --prefix="${dict['prefix']}"
    "${app['ninja']}" --verbose
    "${app['ninja']}" install --verbose
    return 0
}
