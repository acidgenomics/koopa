#!/usr/bin/env bash

main() {
    # """
    # Install Cell Ranger.
    # @note Updated 2023-06-01.
    #
    # Refdata is accessible here:
    # https://support.10xgenomics.com/single-cell-gene-expression/
    #     software/downloads/latest
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['file']="${dict['version']}.tar.xz"
    dict['url']="${dict['installers_base']}/${dict['name']}/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}" "${dict['libexec']}"
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/bin' 'bin'
    )
    return 0
}
