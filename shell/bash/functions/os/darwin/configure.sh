#!/usr/bin/env bash

# FIXME Use functions here when possible.
koopa::configure_macos() {
    koopa::assert_has_no_args "$#"
    koopa::h1 'Configuring macOS system.'
    koopa::enable_passwordless_sudo
    install-homebrew
    install-homebrew-recipes
    install-python
    install-python-packages
    install-r-cran-gfortran
    install-r-packages
    install-conda
    install-rbenv-ruby
    update-macos-defaults
    koopa::success 'macOS configuration was successful.'
    return 0
}
