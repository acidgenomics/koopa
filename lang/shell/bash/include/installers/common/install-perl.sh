#!/usr/bin/env bash

koopa:::install_perl() { # {{{1
    # """
    # Install Perl.
    # @note Updated 2022-01-25.
    #
    # @seealso
    # - https://www.cpan.org/src/
    # - https://metacpan.org/pod/distribution/perl/INSTALL
    # - https://perlmaven.com/how-to-build-perl-from-source-code
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='perl'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    # All Perl 5 releases are currently organized under '5.0'.
    dict[src_maj_min_ver]="$(koopa::major_version "${dict[version]}").0"
    dict[url]="https://www.cpan.org/src/${dict[src_maj_min_ver]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    koopa::alert_coffee_time
    ./Configure -des -Dprefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # The installer will warn when you skip this step.
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
