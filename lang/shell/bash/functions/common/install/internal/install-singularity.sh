#!/usr/bin/env bash

koopa:::install_singularity() { # {{{1
    # """
    # Install Singularity.
    # @note Updated 2022-01-19.
    #
    # NOTE This is splitting into apptainer and singularity-ce in 2022.
    #
    # @seealso
    # - https://issueexplorer.com/issue/hpcng/singularity/6225
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
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
    if koopa::is_linux
    then
        koopa::activate_opt_prefix 'go'
    elif koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'go'
    fi
    koopa::assert_is_installed 'go'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    # This step is needed to avoid an error when not cloned from git repo.
    if [[ ! -f "${dict[version_file]}" ]]
    then
        koopa::print "${dict[version]}" > "${dict[version_file]}"
    fi
    ./mconfig --prefix="${dict[prefix]}"
    "${app[make]}" -C builddir
    "${app[make]}" -C builddir install
    return 0
}
