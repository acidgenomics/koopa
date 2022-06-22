#!/usr/bin/env bash

main() {
    # """
    # Install Perl package.
    # @note Updated 2022-06-21.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # @seealso
    # - https://www.cpan.org/modules/INSTALL.html
    # - https://perldoc.perl.org/ExtUtils::MakeMaker
    # - https://metacpan.org/pod/local::lib
    # - https://www.perl.com/article/4/2013/3/27/
    #     How-to-install-a-specific-version-of-a-Perl-module-with-CPAN/
    # - https://stackoverflow.com/questions/41527057/
    # - https://kb.iu.edu/d/baiu
    # - http://alumni.soe.ucsc.edu/~you/notes/perl-module-install.html
    # - https://docstore.mik.ua/orelly/weblinux2/modperl/ch03_09.htm
    # - https://blogs.iu.edu/ncgas/2019/05/30/installing-perl-modules-locally/
    # """
    local app bin_file bin_files dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'perl'
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[make]}" ]] || return 1
    [[ -x "${app[perl]}" ]] || return 1
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[name2]="${dict[name]}"
    dict[version2]="${dict[version]}"
    case "${dict[name]}" in
        'ack')
            # App::Ack.
            dict[author]='PETDANCE'
            dict[version2]="v${version}"
            ;;
        # > 'cpanminus')
        # >     # App::cpanminus.
        # >     dict[author]='MIYAGAWA'
        # >     dict[name2]='App-cpanminus'
        # >     ;;
        'exiftool')
            # Image::ExifTool.
            dict[author]='EXIFTOOL'
            dict[name2]='Image-ExifTool'
            ;;
        'rename')
            # File::Rename.
            dict[author]='RMBARKER'
            dict[name2]='File-Rename'
            ;;
        *)
            koopa_stop "Unsupported Perl package: '${dict[name]}'."
            ;;
    esac
    dict[file]="${dict[name2]}-${dict[version2]}.tar.gz"
    dict[url]="https://cpan.metacpan.org/authors/id/\
${dict[author]:0:1}/${dict[author]:0:2}/${dict[author]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name2]}-${dict[version2]}"
    # Harden against any undesirable variables set by user.
    unset -v \
        PERL5LIB \
        PERL_BASE \
        PERL_LOCAL_LIB_ROOT \
        PERL_MB_OPT \
        PERL_MM_OPT
    koopa_assert_is_file 'Makefile.PL'
    "${app[perl]}" 'Makefile.PL' INSTALL_BASE="${dict[prefix]}"
    "${app[make]}"
    # > "${app[make]}" test
    "${app[make]}" install
    # Ensure we burn Perl library path into executables. This will add a line
    # directly under the shebang.
    dict[perl_ver]="$(koopa_get_version "${app[perl]}")"
    dict[perl_maj_ver]="$(koopa_major_version "${dict[perl_ver]}")"
    dict[lib_prefix]="${dict[prefix]}/lib/perl${dict[perl_maj_ver]}"
    koopa_assert_is_dir "${dict[lib_prefix]}"
    # > dict[lib_string]="BEGIN { unshift @INC, \"${dict[lib_prefix]}\"; }"
    dict[lib_string]="use lib \"${dict[lib_prefix]}\";"
    readarray -t bin_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[prefix]}/bin" \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${bin_files[@]:-}"
    koopa_assert_is_file "${bin_files[@]}"
    for bin_file in "${bin_files[@]}"
    do
        koopa_alert "Modifying '${bin_file}'."
        koopa_insert_at_line_number \
            --file="$bin_file" \
            --line-number=2 \
            --string="${dict[lib_string]}"
    done
    return 0
}
