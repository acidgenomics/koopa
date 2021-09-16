#!/usr/bin/env bash

# FIXME Standardize this with other package installers.
koopa::install_r_packages() { # {{{1
    koopa::install_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        --no-link \
        --no-prefix-check \
        --prefix="$(koopa::r_packages_prefix)" \
        "$@"
}

koopa:::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2021-09-16.
    # """
    koopa::configure_r
    koopa::r_koopa 'cliInstallRPackages' "$@"
    return 0
}

# FIXME Standard this with other package manager functions.
koopa::uninstall_r_packages() { # {{{1
    # """
    # Uninstall R packages.
    # @note Updated 2021-06-14.
    # """
    koopa::uninstall_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        --no-link \
        "$@"
}

# FIXME Need to wrap this in 'update_app' call.
koopa::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-08-14.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='R packages'
    pkg_prefix="$(koopa::r_packages_prefix)"
    koopa::update_start "$name_fancy"
    koopa::configure_r
    koopa::assert_is_dir "$pkg_prefix"
    # Return with success even if 'BiocManager::valid()' check returns false.
    koopa::r_koopa 'cliUpdateRPackages' "$@" || true
    koopa::sys_set_permissions -r "$pkg_prefix"
    koopa::update_success "$name_fancy"
    return 0
}
