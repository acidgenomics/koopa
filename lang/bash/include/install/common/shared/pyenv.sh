#!/usr/bin/env bash


main() {
    # """
    # Install pyenv.
    # @note Updated 2025-05-05.
    #
    # @seealso
    # - https://github.com/pyenv/pyenv
    # - https://github.com/pyenv/pyenv-virtualenv
    # - https://github.com/macdub/pyenv-multiuser
    # """
    local -A app dict
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
    # Install pyenv-virtualenv plugin.
    dict['virtualenv_version']='1.2.4'
    dict['virtualenv_url']="https://github.com/pyenv/pyenv-virtualenv/archive/\
refs/tags/v${dict['virtualenv_version']}.tar.gz"
    koopa_download "${dict['virtualenv_url']}" 'virtualenv-src.tar.gz'
    koopa_extract \
        'virtualenv-src.tar.gz' \
        "${dict['prefix']}/plugins/pyenv-virtualenv"
    app['pyenv']="${dict['prefix']}/bin/pyenv"
    app['sed']="$(koopa_locate_sed)"
    koopa_assert_is_executable "${app[@]}"
    koopa_mkdir 'bin'
    (
        koopa_cd 'bin'
        koopa_ln "${app['sed']}" 'sed'
    )
    koopa_add_to_path_start 'bin'
    "${app['pyenv']}" --version
    koopa_alert 'Configuring pyenv-multiuser plugin.'
    export PYENV_ROOT="${dict['prefix']}"
    "${app['pyenv']}" multiuser setup
    koopa_rm --verbose "${dict['prefix']}/plugins/pyenv-multiuser/backup"
    "${app['pyenv']}" multiuser status
    return 0

}
