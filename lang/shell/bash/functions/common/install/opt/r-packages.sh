#!/usr/bin/env bash

# FIXME Standardize this with other package installers.
koopa::install_r_packages() { # {{{1
    koopa:::install_app \
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

koopa::uninstall_r_packages() { # {{{1
    # """
    # Uninstall R packages.
    # @note Updated 2021-06-14.
    # """
    koopa:::uninstall_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        --no-link \
        "$@"
}

koopa::update_r_packages() { # {{{1
    koopa:::update_app \
        --name-fancy='R packages' \
        --name='r-packages'
}

koopa:::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-09-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::configure_r
    # Return with success even if 'BiocManager::valid()' check returns false.
    koopa::r_koopa 'cliUpdateRPackages' "$@" || true
    return 0
}
