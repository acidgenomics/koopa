#!/usr/bin/env bash

koopa::list_cellar_versions() {
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::cellar_prefix)"
    (
        koopa::cd "$prefix"
        ls -1 -- *
    )
    return 0
}

koopa::remove_broken_cellar_symlinks() {
    koopa::assert_has_no_args "$#"
    koopa::remove_broken_symlinks "$(koopa::make_prefix)"
    return 0
}
