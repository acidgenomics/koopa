#!/usr/bin/env bash

main() {
    # """
    # Install Apptainer.
    # @note Updated 2023-03-27.
    #
    # @seealso
    # - https://github.com/apptainer/apptainer
    # - https://issueexplorer.com/issue/hpcng/singularity/6225
    # """
    local app conf_args dict
    declare -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go' 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['name']='apptainer'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['version_file']='VERSION'
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/apptainer/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # This step is needed to avoid an error when not cloned from git repo.
    if [[ ! -f "${dict['version_file']}" ]]
    then
        koopa_print "${dict['version']}" > "${dict['version_file']}"
    fi
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--without-suid'
        '-P' 'release-stripped'
        '-v'
    )
    koopa_print_env
    ./mconfig "${conf_args[@]}"
    "${app['make']}" -C 'builddir'
    "${app['make']}" -C 'builddir' install
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
