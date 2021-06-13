#!/usr/bin/env bash

koopa::configure_perl() { # {{{1
    # """
    # Configure Perl.
    # @note Updated 2021-06-11.
    # """
    local prefix version
    version="$(koopa::get_version 'perl')"
    prefix="$(koopa::perl_packages_prefix "$version")"
    koopa::link_into_opt "$prefix" 'perl-packages'
    return 0
}
