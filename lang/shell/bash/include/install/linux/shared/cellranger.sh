#!/usr/bin/env bash

# FIXME Need to rework to download via s3 instead.

main() {
    # """
    # Install Cell Ranger.
    # @note Updated 2023-01-03.
    #
    # Refdata is accessible here:
    # https://support.10xgenomics.com/single-cell-gene-expression/
    #     software/downloads/latest
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['installers_url']="$(koopa_private_installers_url)"
        ['name']='cellranger'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="${dict['installers_url']}/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_mv "${dict['name']}-${dict['version']}" "${dict['libexec']}"
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/bin' 'bin'
    )
    return 0
}
