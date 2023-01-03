#!/usr/bin/env bash

# FIXME Install this into libexec and then just copy the binary.
# FIXME Consider informing user interactively regarding license agreement.

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
        ['installers_url']="$(koopa_koopa_installers_url)"
        ['name']='cellranger'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="${dict['installers_url']}/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_mv "${dict['name']}-${dict['version']}" "${dict['prefix']}"
    return 0
}
