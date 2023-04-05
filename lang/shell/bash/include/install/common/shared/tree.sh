#!/usr/bin/env bash

main() {
    # """
    # Install tree.
    # @note Updated 2022-04-10.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/tree.html
    # - https://gist.github.com/fscm/9eee2784f101f21515d66321180aef0f
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    local -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['name']='tree'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tgz"
    dict['url']="http://mama.indstate.edu/users/ice/${dict['name']}/src/\
${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}"
    "${app['make']}" \
        PREFIX="${dict['prefix']}" \
        MANDIR="${dict['prefix']}/share/man" \
        install
    return 0
}
