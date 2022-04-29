#!/usr/bin/env bash

main() { # {{{
    # """
    # Install libxml2.
    # @note Updated 2022-04-28.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libxml2.html
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    # NOTE May need Python here.
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix 'icu4c' 'readline'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libxml2'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://download.gnome.org/sources/${dict[name]}/\
${dict[maj_min_ver]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        # > '--with-history'
        # > "--with-python=${dict[opt_prefix]}/python/bin/python3"
        "--prefix=${dict[prefix]}"
        '--enable-static'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
