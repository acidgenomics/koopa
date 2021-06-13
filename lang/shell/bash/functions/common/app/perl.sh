#!/usr/bin/env bash

koopa::configure_perl() { # {{{1
    # """
    # Configure Perl.
    # @note Updated 2021-06-13.
    # """
    local prefix version
    koopa::assert_is_installed 'perl'
    version="$(koopa::get_version 'perl')"
    prefix="$(koopa::perl_packages_prefix "$version")"
    koopa::link_into_opt "$prefix" 'perl-packages'
    PERL_MM_OPT="INSTALL_BASE=$prefix" cpan 'local::lib'
    eval "$( \
        perl \
            "-I${prefix}/lib/perl5" \
            "-Mlocal::lib=${prefix}" \
    )"
    return 0
}
