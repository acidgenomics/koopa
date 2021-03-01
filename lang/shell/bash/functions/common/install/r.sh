#!/usr/bin/env bash

koopa::install_r_cmd_check() { # {{{1
    # """
    # Install R CMD check (Rcheck) scripts for CI.
    # @note Updated 2021-03-01.
    # """
    local link_name name source_repo target_dir
    koopa::assert_has_no_args "$#"
    name='r-cmd-check'
    source_repo="https://github.com/acidgenomics/${name}.git"
    target_dir="$(koopa::local_data_prefix)/${name}"
    link_name='.Rcheck'
    koopa::install_start "$name"
    if [[ ! -d "$target_dir" ]]
    then
        koopa::alert "Downloading ${name} to '${target_dir}'."
        (
            koopa::mkdir "$target_dir"
            git clone "$source_repo" "$target_dir"
        )
    fi
    koopa::ln "$target_dir" "$link_name"
    koopa::install_success "$name"
    return 0
}

koopa::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2021-01-19.
    # """
    koopa::h1 'Installing R packages.'
    koopa::rscript 'installRPackages' "$@"
    return 0
}

koopa::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-01-19.
    # """
    koopa::h1 'Updating R packages.'
    koopa::rscript 'updateRPackages' "$@"
    return 0
}
