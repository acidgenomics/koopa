#!/usr/bin/env bash

# FIXME s3://private.koopa.acidgenomics.com/installers/ont-guppy/linux/amd64/6.4.2-cpu.tar.gz

main() {
    # """
    # Install Oxford Nanopore guppy caller.
    # @note Updated 2023-01-10.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    # FIXME koopa_assert_has_private_access
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['installers_url']="$(koopa_private_installers_url)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['file']="${dict['version']}.tar.xz"
    dict['url']="${dict['installers_url']}/${dict['name']}/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_mv "${dict['name']}-${dict['version']}" "${dict['libexec']}"
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/bin' 'bin'
    )
    return 0
}
