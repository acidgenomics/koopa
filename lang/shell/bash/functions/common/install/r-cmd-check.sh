#!/usr/bin/env bash

# FIXME Rework the install target here...
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
