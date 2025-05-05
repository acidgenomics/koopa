#!/usr/bin/env bash

# FIXME Consider installing this per user instead of for all users.

# FIXME Use pyenv-multiuser for this:
# https://github.com/macdub/pyenv-multiuser
# PYENV_LOCAL_SHIM needs to be set during activation.
# > pyenv multiuser setup
# > pyenv multiuser init [PATH]

main() {
    # """
    # Install pyenv.
    # @note Updated 2025-05-05.
    #
    # @seealso
    # - https://github.com/pyenv/pyenv
    # - https://github.com/macdub/pyenv-multiuser
    # """
    local -A dict
    local -a dirs
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/pyenv/pyenv/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}" 'src.tar.gz'
    koopa_extract 'src.tar.gz' "${dict['prefix']}"
    dirs=(
        "${dict['prefix']}/shims"
        "${dict['prefix']}/versions"
    )
    koopa_mkdir "${dirs[@]}"
    koopa_chmod 0777 "${dirs[@]}"
    # Install pyenv-multiuser plugin.
    dict['multiuser_version']='1.0.8'
    dict['multiuser_url']="https://github.com/macdub/pyenv-multiuser/archive/\
refs/tags/${dict['multiuser_version']}.tar.gz"
    koopa_download "${dict['multiuser_url']}" 'multiuser-src.tar.gz'
    koopa_extract \
        'multiuser-src.tar.gz' \
        "${dict['prefix']}/plugins/pyenv-multiuser"
    return 0
}
