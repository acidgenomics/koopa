#!/usr/bin/env bash

main() {
    # """
    # Install Apptainer.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://github.com/apptainer/apptainer
    # - https://issueexplorer.com/issue/hpcng/singularity/6225
    # """
    local -A app dict
    local -a conf_args
    _koopa_activate_app --build-only 'go' 'make' 'pkg-config'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/apptainer/apptainer/archive/refs/\
tags/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    # This step is needed to avoid an error when not cloned from git repo.
    if [[ ! -f 'VERSION' ]]
    then
        _koopa_print "${dict['version']}" > 'VERSION'
    fi
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--without-suid'
        '-P' 'release-stripped'
        '-v'
    )
    _koopa_print_env
    ./mconfig "${conf_args[@]}"
    "${app['make']}" -C 'builddir'
    "${app['make']}" -C 'builddir' install
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
