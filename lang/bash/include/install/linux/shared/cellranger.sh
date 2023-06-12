#!/usr/bin/env bash

main() {
    # """
    # Install Cell Ranger.
    # @note Updated 2023-06-12.
    #
    # Refdata is accessible here:
    # https://support.10xgenomics.com/single-cell-gene-expression/
    #     software/downloads/latest
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['url']="${dict['installers_base']}/cellranger/\
${dict['version']}.tar.xz"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp \
        "${dict['url']}" \
        "$(koopa_basename "${dict['url']}")"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['libexec']}"
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/bin' 'bin'
    )
    return 0
}
