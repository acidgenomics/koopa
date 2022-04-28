#!/usr/bin/env bash

# NOTE This is currently failing to build on macOS.

main() { # {{{1
    # """
    # Install the silver searcher.
    # @note Updated 2022-04-13.
    #
    # Ag has been renamed to The Silver Searcher.
    #
    # Current tagged release hasn't been updated in a while and has a lot of 
    # bug fixes on GitHub, including GCC 10 support, which is required for
    # Fedora 32.
    #
    # GPG signed releases:
    # > file="${name2}-${version}.tar.gz"
    # > url="https://geoff.greer.fm/ag/releases/${file}"
    #
    # Tagged GitHub release.
    # > file="${version}.tar.gz"
    # > url="https://github.com/ggreer/${name2}/archive/${file}"
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix \
        'autoconf' \
        'automake' \
        'libtool' \
        'pkg-config'
    # Use 'PCRE' not 'PCRE2' here.
    # Need to add 'zlib' on Linux?
    koopa_activate_opt_prefix \
        'gettext' \
        'pcre'
    declare -A app=(
        [autoreconf]="$(koopa_locate_autoreconf)"
        [libtoolize]="$(koopa_locate_libtoolize)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='the-silver-searcher'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[name2]="$(koopa_snake_case_simple "${dict[name]}")"
    dict[url_stem]="https://github.com/ggreer/${dict[name2]}"
    case "${dict[version]}" in
        '2.2.0')
            dict[commit]='a61f1780b64266587e7bc30f0f5f71c6cca97c0f'
            dict[file]="${dict[commit]}.tar.gz"
            dict[url]="${dict[url_stem]}/archive/${dict[file]}"
            dict[dirname]="${dict[name2]}-${dict[commit]}"
            ;;
        *)
            dict[file]="${dict[version]}.tar.gz"
            dict[url]="${dict[url_stem]}/archive/refs/tags/${dict[file]}"
            dict[dirname]="${dict[name2]}-${dict[version]}"
            ;;
    esac
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[dirname]}"
    "${app[libtoolize]}"
    "${app[autoreconf]}" -iv
    # Refer to 'build.sh' and 'autogen.sh' scripts for details.
    # From the 'autogen.sh' script:
    # > if [ -d "/usr/local/share/aclocal" ]
    # > then
    # >     AC_SEARCH_OPTS="-I /usr/local/share/aclocal"
    # > fi
    # > aclocal # $AC_SEARCH_OPTS
    # > autoconf
    # > autoheader
    # > automake --add-missing
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
