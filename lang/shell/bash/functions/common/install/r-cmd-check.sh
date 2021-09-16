#!/usr/bin/env bash

koopa::install_r_cmd_check() { # {{{1
    koopa:::install_app \
        --name='r-cmd-check' \
        --no-link \
        "$@"
}

koopa:::install_r_cmd_check() { # {{{1
    # """
    # Install r-cmd-check scripts for CI.
    # @note Updated 2021-06-07.
    # """
    local prefix source_repo
    prefix="${INSTALL_PREFIX:?}"
    source_repo='https://github.com/acidgenomics/r-cmd-check.git'
    koopa::mkdir "$prefix"
    koopa::git_clone "$source_repo" "$prefix"
    return 0
}

koopa::uninstall_r_cmd_check() { # {{{1
    koopa:::uninstall_app \
        --name='r-cmd-check' \
        --no-link \
        "$@"
}

koopa::update_r_cmd_check() { # {{{1
    # """
    # Update r-cmd-check scripts.
    # @note Updated 2021-06-07.
    # """
    local name name_fancy prefix
    koopa::assert_has_no_args "$#"
    name='r-cmd-check'
    name_fancy="$name"
    koopa::update_start "$name_fancy"
    prefix="$(koopa::opt_prefix)/${name}"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    koopa::update_success "$name_fancy"
    return 0
}
