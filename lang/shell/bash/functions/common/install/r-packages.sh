#!/usr/bin/env bash

# FIXME Add an uninstaller that prompts for confirmation.

koopa::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2021-05-25.
    # """
    local name_fancy pkg_prefix
    name_fancy='R packages'
    pkg_prefix="$(koopa::r_packages_prefix)"
    koopa::install_start "$name_fancy"
    koopa::configure_r
    koopa::assert_is_dir "$pkg_prefix"
    koopa::rscript 'installRPackages' "$@"
    koopa::sys_set_permissions -r "$pkg_prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-06-03.
    # """
    local name_fancy
    name_fancy='R packages'
    pkg_prefix="$(koopa::r_packages_prefix)"
    koopa::update_start "$name_fancy"
    koopa::configure_r
    koopa::assert_is_dir "$pkg_prefix"
    # Return with success even if 'BiocManager::valid()' check returns false.
    koopa::rscript 'updateRPackages' "$@" || true
    koopa::sys_set_permissions -r "$pkg_prefix"
    koopa::update_success "$name_fancy"
    return 0
}
