#!/usr/bin/env bash

koopa:::linux_install_cellranger() { # {{{1
    # """
    # Install Cell Ranger.
    # @note Updated 2021-11-16.
    #
    # Refdata is accessible here:
    # https://support.10xgenomics.com/single-cell-gene-expression/
    #     software/downloads/latest
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [name]='cellranger'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://seq.cloud/install/cellranger/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::sys_mv "${dict[name]}-${dict[version]}" "${dict[prefix]}"
    return 0
}
