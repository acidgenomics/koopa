#!/usr/bin/env bash

# [2021-05-27] macOS success.

# FIXME Need to harden which Perl here more clearly.
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

koopa::install_perl() { # {{{1
    koopa::install_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa:::install_perl() { # {{{1
    # """
    # Install Perl.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://www.cpan.org/src/
    # - https://metacpan.org/pod/distribution/perl/INSTALL
    # - https://perlmaven.com/how-to-build-perl-from-source-code
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='perl'
    file="${name}-${version}.tar.gz"
    url="https://www.cpan.org/src/5.0/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::alert_coffee_time
    ./Configure -des -Dprefix="$prefix"
    "$make" --jobs="$jobs"
    # The installer will warn when you skip this step.
    # > "$make" test
    "$make" install
    return 0
}

koopa::uninstall_perl() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}
