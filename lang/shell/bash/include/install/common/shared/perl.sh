#!/usr/bin/env bash

# NOTE Consider including 'expat', 'gdbm', and possibly 'zlib' here?

main() {
    # """
    # Install Perl.
    # @note Updated 2022-06-21.
    #
    # @seealso
    # - https://www.cpan.org/src/
    # - https://metacpan.org/pod/distribution/perl/INSTALL
    # - https://perlmaven.com/how-to-build-perl-from-source-code
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='perl'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    # All Perl 5 releases are currently organized under '5.0'.
    dict['src_maj_min_ver']="$(koopa_major_version "${dict['version']}").0"
    dict['url']="https://www.cpan.org/src/${dict['src_maj_min_ver']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    ./Configure -des -Dprefix="${dict['prefix']}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # The installer will warn when you skip this step.
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
