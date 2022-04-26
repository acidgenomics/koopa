#!/usr/bin/env bash

main() { #{{{1
    # """
    # Install Apache Portable Runtime (APR) library.
    # @note Updated 2022-04-09.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/apr.rb
    # - macOS build issue:
    #  https://bz.apache.org/bugzilla/show_bug.cgi?id=64753
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    if koopa_is_macos
    then
        koopa_activate_build_opt_prefix 'autoconf' 'automake' 'libtool'
    fi
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    if koopa_is_macos
    then
        app[autoreconf]="$(koopa_locate_autoreconf)"
        app[patch]="$(koopa_locate_patch)"
    fi
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='apr'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://archive.apache.org/dist/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
    )
    if koopa_is_macos
    then
        # Apply r1871981 which fixes a compile error on macOS 11.0.
        koopa_cd "${dict[name]}-${dict[version]}"
        koopa_download \
            "https://raw.githubusercontent.com/Homebrew/\
formula-patches/7e2246542543bbd3111a4ec29f801e6e4d538f88/\
apr/r1871981-macos11.patch" \
            'patch1.patch'
        "${app[patch]}" -p0 --input='patch1.patch'
        # Apply r1882980+1882981 to fix implicit exit() declaration
        # Remove with the next release, along with autoconf dependency.
        koopa_cd ..
        koopa_download \
            "https://raw.githubusercontent.com/Homebrew/\
formula-patches/fa29e2e398c638ece1a72e7a4764de108bd09617/apr/\
r1882980%2B1882981-configure.patch" \
            'patch2.patch'
        "${app[patch]}" -p0 --input='patch2.patch'
        koopa_cd "${dict[name]}-${dict[version]}"
        koopa_rm 'configure'
        # This step requires autoconf, automake, and libtool.
        "${app[autoreconf]}" --install
        koopa_cd ..
    fi
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
