#!/usr/bin/env bash

# FIXME Consider installing GNU patch to resolve here, without prompting.

# FIXME Still hitting these issues on macOS:
# ./include/apr.h:561:2: error: Can not determine the proper size for pid_t
# ./include/apr_want.h:94:8: error: redefinition of 'iovec'

# FIXME Consider switching to GNU GCC here to build...

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
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [patch]="$(koopa_locate_patch)"
    )
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
    # Apply r1871981 which fixes a compile error on macOS 11.0.
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_download \
        "https://raw.githubusercontent.com/Homebrew/\
formula-patches/7e2246542543bbd3111a4ec29f801e6e4d538f88/\
apr/r1871981-macos11.patch" \
        'patch1.patch'
    "${app[patch]}" -p0 --input='patch1.patch'
    # Apply r1882980+1882981 to fix implicit exit() declaration
    # Remove with the next release, along with the autoconf call & dependency.
    koopa_cd ..
    koopa_download \
        "https://raw.githubusercontent.com/Homebrew/\
formula-patches/fa29e2e398c638ece1a72e7a4764de108bd09617/apr/\
r1882980%2B1882981-configure.patch" \
        'patch2.patch'
    "${app[patch]}" -p0 --input='patch2.patch'
    koopa_cd "${dict[name]}-${dict[version]}"
    # > koopa_rm 'configure'
    # > autoreconf
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
