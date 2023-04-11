#!/usr/bin/env bash

# NOTE Consider including 'expat', 'gdbm', and possibly 'zlib' here.
#
# FIXME This is no longer building Perl documentation files.
# Seeing 'Manual disabled by Configure' message.

# FIXME Restrict /usr/local here:
# [-fno-common -DPERL_DARWIN -mmacosx-version-min=13.3 -fno-strict-aliasing -pipe -fstack-protector-strong -I/usr/local/include]
# [ -mmacosx-version-min=13.3 -fstack-protector-strong -L/usr/local/lib]

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
    # - https://metacpan.org/dist/perl/view/INSTALL
    # - https://metacpan.org/pod/distribution/perl/INSTALL
    # - https://perlmaven.com/how-to-build-perl-from-source-code
    # - https://github.com/conda-forge/perl-feedstock
    # - https://github.com/Perl/perl5/blob/blead/Configure
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'groff' 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['man1dir']="${dict['prefix']}/share/man/man1"
    dict['man3dir']="${dict['prefix']}/share/man/man3"
    dict['sysman']="${dict['prefix']}/share/man/man1"
    conf_args=(
        '-d'
        '-e'
        '-s'
        '-Dcf_by=koopa'
        '-Dcf_email=koopa'
        '-Dinc_version_list=none'
        "-Dman1dir=${dict['man1dir']}"
        "-Dman3dir=${dict['man3dir']}"
        '-Dmydomain=.koopa'
        '-Dmyhostname=koopa'
        '-Dperladmin=koopa'
        "-Dprefix=${dict['prefix']}"
        "-Dsysman=${dict['sysman']}"
        '-Duse64bitall'
        '-Duselargefiles'
        '-Duseshrplib'
        '-Dusethreads'
    )
    koopa_is_linux && dict['jobs']=1
    # All Perl 5 releases are currently organized under '5.0'.
    dict['src_maj_min_ver']="$(koopa_major_version "${dict['version']}").0"
    dict['url']="https://www.cpan.org/src/${dict['src_maj_min_ver']}/\
perl-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_mkdir \
        "${dict['man1dir']}" \
        "${dict['man3dir']}" \
        "${dict['sysman']}"
    ./Configure -h || true
    ./Configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
