#!/usr/bin/env bash

# FIXME Should we rework the version approach here now?

koopa:::install_the_silver_searcher() { # {{{1
    # """
    # Install the silver searcher.
    # @note Updated 2022-01-03.
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
    #
    # Note that Fedora has changed pkg-config to pkgconf, which is causing
    # issues with ag building from source. Install the regular pkg-config from
    # source to fix this build issue.
    # https://fedoraproject.org/wiki/Changes/
    #     pkgconf_as_system_pkg-config_implementation
    # In this case, you'll see this error:
    # # ./configure: [...] syntax error near unexpected token `PCRE,'
    # # ./configure: [...] `PKG_CHECK_MODULES(PCRE, libpcre)'
    # https://github.com/ggreer/the_silver_searcher/issues/341
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='the-silver-searcher'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[name2]="$(koopa::snake_case_simple "${dict[name]}")"
    # Temporary fix for installation of current version, which has bug fixes
    # that aren't yet available in tagged release, especially for GCC 10.
    dict[url_stem]="https://github.com/ggreer/${dict[name2]}/archive"
    case "${dict[version]}" in
        '2.2.0')
            dict[version]='master'
            ;;
        *)
            dict[url_stem]="${dict[url_stem]}/refs/tags"
            ;;
    esac
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="${dict[url_stem]}/${dict[file]}"
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'pcre' 'pkg-config'
    fi
    koopa::assert_is_installed 'pcre-config' 'pkg-config'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name2]}-${dict[version]}"
    # Refer to 'build.sh' script for details.
    ./autogen.sh
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
