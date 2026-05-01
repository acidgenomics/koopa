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
    app['aws']="$(_koopa_locate_aws --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['installers_base']="$(_koopa_private_installers_s3_uri)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    dict['url']="${dict['installers_base']}/cellranger/\
${dict['version']}.tar.xz"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp \
        "${dict['url']}" \
        "$(_koopa_basename "${dict['url']}")"
    _koopa_extract \
        "$(_koopa_basename "${dict['url']}")" \
        "${dict['libexec']}"
    (
        _koopa_cd "${dict['prefix']}"
        _koopa_ln 'libexec/bin' 'bin'
    )
    return 0
}
