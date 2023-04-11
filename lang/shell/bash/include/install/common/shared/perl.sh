#!/usr/bin/env bash

# NOTE Consider including 'expat', 'gdbm', and possibly 'zlib' here.
# FIXME This is no longer building Perl documentation files.

main() {
    # """
    # Install Perl.
    # @note Updated 2023-04-11.
    #
    # @section Regarding parallel build failures on Ubunutu:
    # make can error at this step when running in parallel.
    # # Updating 'mktables.lst'
    # - https://www.nntp.perl.org/group/perl.perl5.porters/2016/
    #     09/msg239501.html
    # - https://github.com/Perl/perl5/issues/17541
    #
    # @seealso
    # - https://www.cpan.org/src/
    # - https://metacpan.org/pod/distribution/perl/INSTALL
    # - https://perlmaven.com/how-to-build-perl-from-source-code
    #
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_is_linux && dict['jobs']=1
    # All Perl 5 releases are currently organized under '5.0'.
    dict['src_maj_min_ver']="$(koopa_major_version "${dict['version']}").0"
    dict['url']="https://www.cpan.org/src/${dict['src_maj_min_ver']}/\
perl-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    ./Configure -des -Dprefix="${dict['prefix']}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
