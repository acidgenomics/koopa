#!/usr/bin/env bash

# FIXME This is a go package. Work on building from source.
# FIXME Rename this to 'docker-credential-helpers'.
# FIXME Rework this approach.

main() {
    # """
    # Install docker-credential-pass.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['name']='docker-credential-pass'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-v${dict['version']}.linux-${dict['arch']}"
    dict['url']="https://github.com/docker/docker-credential-helpers/releases/\
download/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod '0775' "${dict['file']}"
    koopa_cp "${dict['file']}" "${dict['prefix']}/bin/${dict['name']}"
    return 0
}
