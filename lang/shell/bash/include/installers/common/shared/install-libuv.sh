#!/usr/bin/env bash

# NOTE Consider adding support for 'sphinx-doc'.

main() {
    # """
    # Install libuv.
    # @note Updated 2022-04-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libuv.rb
    # - https://cran.r-project.org/web/packages/httpuv/index.html
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'autoconf' \
        'automake' \
        'libtool' \
        'pkg-config'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libuv'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    # Need to create g-prefixed libtools symlinks, otherwise the build will
    # fail on macOS.
    dict[opt_prefix]="$(koopa_opt_prefix)"
    dict[bin_extra]="$(koopa_init_dir 'bin-extra')"
    koopa_ln \
        "${dict[opt_prefix]}/libtool/bin/libtoolize" \
        "${dict[bin_extra]}/glibtoolize"
    koopa_add_to_path_start "${dict[bin_extra]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
    )
    # This tries to locate 'glibtoolize'.
    ./autogen.sh
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
