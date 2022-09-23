#!/usr/bin/env bash

main() {
    # """
    # Install csvtk.
    # @note Updated 2022-09-23.
    #
    # @seealso
    # - https://github.com/shenwei356/csvtk
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/csvtk.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'go'
    declare -A app=(
        ['go']="$(koopa_locate_go)"
    )
    [[ -x "${app['go']}" ]] || return 1
    declare -A dict=(
        ['gopath']="$(koopa_init_dir 'go')"
        ['name']='csvtk'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/shenwei356/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    export GOPATH="${dict['gopath']}"
    dict['ldflags']='-s -w'
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${dict['prefix']}/bin/csvtk" \
        ./csvtk
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
