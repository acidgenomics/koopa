#!/usr/bin/env bash

# [2021-09-17] macOS success.

# FIXME Need to ensure that correct Perl is in PATH.
koopa::configure_perl() { # {{{1
    # """
    # Configure Perl.
    # @note Updated 2021-09-17.
    # """
    local perl prefix yes
    koopa::assert_has_no_args "$#"
    perl="$(koopa::locate_perl)"
    koopa:::configure_app_packages \
        --name='perl' \
        --name-fancy='Perl' \
        --which-app="$perl"
    prefix="$(koopa::perl_packages_prefix)"
    koopa::assert_is_dir "$prefix"
    # Ensure we start with a clean CPAN configuration.
    koopa::rm "${HOME}/.cpan"
    koopa::alert "Setting up 'local::lib' at '${prefix}' using CPAN."
    koopa::add_to_path_start "$(koopa::dirname "$perl")"
    # FIXME Need to add support for this.
    yes="$(koopa::locate_yes)"
    # FIXME This is prompting, which we don't want.
    "$yes" \
        | PERL_MM_OPT="INSTALL_BASE=$prefix" \
            cpan 'local::lib'
    eval "$( \
        "$perl" \
            "-I${prefix}/lib/perl5" \
            "-Mlocal::lib=${prefix}" \
    )"
    return 0
}

koopa::install_perl() { # {{{1
    koopa:::install_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
    koopa::configure_perl
    return 0
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
    koopa:::uninstall_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}
