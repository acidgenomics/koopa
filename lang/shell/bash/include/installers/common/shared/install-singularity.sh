#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Singularity.
    # @note Updated 2022-04-07.
    #
    # NOTE This is splitting into apptainer and singularity-ce in 2022.
    #
    # @seealso
    # - https://issueexplorer.com/issue/hpcng/singularity/6225
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'go'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='singularity'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [version_file]='VERSION'
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/apptainer/${dict[name]}/archive/refs/\
tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # This step is needed to avoid an error when not cloned from git repo.
    if [[ ! -f "${dict[version_file]}" ]]
    then
        koopa_print "${dict[version]}" > "${dict[version_file]}"
    fi
    ./mconfig --prefix="${dict[prefix]}"
    "${app[make]}" -C builddir
    "${app[make]}" -C builddir install
    return 0
}
