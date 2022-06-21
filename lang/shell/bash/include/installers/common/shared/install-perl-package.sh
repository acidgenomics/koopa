#!/usr/bin/env bash

main() {
    # """
    # Install Perl packages.
    # @note Updated 2022-06-21.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # @seealso
    # - https://www.cpan.org/modules/INSTALL.html
    # - https://metacpan.org/pod/local::lib
    # - https://www.perl.com/article/4/2013/3/27/
    #     How-to-install-a-specific-version-of-a-Perl-module-with-CPAN/
    # - https://stackoverflow.com/questions/41527057/
    # - https://kb.iu.edu/d/baiu
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'perl'
    declare -A app=(
        [cpan]="$(koopa_locate_perl)"
        [perl]="$(koopa_locate_perl)"
        [yes]="$(koopa_locate_yes)"
    )
    [[ -x "${app[cpan]}" ]] || return 1
    [[ -x "${app[perl]}" ]] || return 1
    [[ -x "${app[yes]}" ]] || return 1
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[version2]="${dict[version]}"
    case "${dict[name]}" in
        'ack')
            # App::Ack.
            dict[repo]='PETDANCE/ack'
            dict[version2]="v${version}"
            ;;
        'cpanminus')
            # App::cpanminus.
            dict[repo]='MIYAGAWA/App-cpanminus'
            ;;
        'exiftool')
            # Image::ExifTool.
            dict[repo]='EXIFTOOL/Image-ExifTool'
            ;;
        'rename')
            # File::Rename.
            dict[repo]='RMBARKER/File-Rename'
            ;;
        *)
            koopa_stop "Unsupported Perl package: '${dict[name]}'."
            ;;
    esac
    dict[module]="${dict[repo]}-${dict[version2]}"
    unset -v PERL5LIB PERL_BASE
    "${app[yes]}" \
        | PERL_MM_OPT="INSTALL_BASE=${dict[prefix]}" \
            "${app[cpan]}" -f -i 'local::lib' \
            &>/dev/null \
        || true
    eval "$( \
        "${app[perl]}" \
        "-Mlocal::lib=${dict[prefix]}" \
        "-I${dict[prefix]}/lib/perl5" \
        &>/dev/null \
    )"
    # Alternative approach:
    # > "${app[perl]}" \
    # >     -MCPAN \
    # >     -Mlocal::lib \
    # >     -e "CPAN::install(${dict[module]})"
    "${app[cpan]}" -i "${dict[module]}.tar.gz"
    return 0
}
