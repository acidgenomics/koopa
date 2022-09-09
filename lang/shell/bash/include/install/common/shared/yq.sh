#!/usr/bin/env bash

main() {
    # """
    # Install yq.
    # @note Updated 2022-07-28.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/yq.rb
    # - go help build
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
        ['name']='yq'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/mikefarah/yq/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['go']}" build
    koopa_cp --target-directory="${dict['prefix']}/bin" 'yq'
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
