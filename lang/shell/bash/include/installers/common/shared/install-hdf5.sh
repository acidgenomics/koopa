#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install HDF5.
    # @note Updated 2021-12-07.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='hdf5'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        # Using R CRAN gfortran here.
        dict[gfortran_prefix]='/usr/local/gfortran'
        koopa_assert_is_dir "${dict[gfortran_prefix]}"
        koopa_activate_prefix "${dict[gfortran_prefix]}"
    fi
    koopa_assert_is_installed 'gfortran'
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://support.hdfgroup.org/ftp/HDF5/releases/\
${dict[name]}-${dict[maj_min_ver]}/${dict[name]}-${dict[version]}/\
src/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-cxx'
        '--enable-fortran'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}
