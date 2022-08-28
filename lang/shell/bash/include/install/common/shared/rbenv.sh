#!/usr/bin/env bash

main() {
    # """
    # Install rbenv.
    # @note Updated 2022-07-14.
    #
    # @seealso
    # - https://github.com/rbenv/rbenv
    # - https://github.com/rbenv/ruby-build
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['name']='rbenv'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/archive/\
refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp "${dict['name']}-${dict['version']}" "${dict['prefix']}"
    koopa_mkdir "${dict['prefix']}/plugins"
    koopa_git_clone \
        --prefix="${dict['prefix']}/plugins/ruby-build" \
        --tag='v20220713' \
        --url='https://github.com/rbenv/ruby-build.git'
    return 0
}
