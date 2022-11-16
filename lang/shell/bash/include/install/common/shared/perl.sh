#!/usr/bin/env bash

# NOTE Consider including 'expat', 'gdbm', and possibly 'zlib' here?
# FIXME This is no longer building Perl documentation files.

main() {
    # """
    # Install Perl.
    # @note Updated 2022-06-21.
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
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='perl'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    # All Perl 5 releases are currently organized under '5.0'.
    dict['src_maj_min_ver']="$(koopa_major_version "${dict['version']}").0"
    dict['url']="https://www.cpan.org/src/${dict['src_maj_min_ver']}/\
${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    ./Configure -des -Dprefix="${dict['prefix']}"
    # Deparallelize on Linux to avoid error at "Updating 'mktables.lst'".
    koopa_is_linux && dict['jobs']=1
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # The installer will warn when you skip this step.
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
