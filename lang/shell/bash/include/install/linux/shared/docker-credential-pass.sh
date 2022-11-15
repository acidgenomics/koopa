#!/usr/bin/env bash

# FIXME This is a go package. Work on building from source.
# FIXME Rename this to 'docker-credential-helpers'.
# FIXME Rework this approach.

main() {
    # """
    # Install docker-credential-pass.
    # @note Updated 2022-11-15.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['name']='docker-credential-pass'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-v${dict['version']}.linux-${dict['arch']}"
    dict['url']="https://github.com/docker/docker-credential-helpers/releases/\
download/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod '0775' "${dict['file']}"
    koopa_mkdir "${dict['prefix']}/bin"
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    koopa_cp --target-directory="${dict['prefix']}/bin" "${dict['file']}"
    return 0
}
