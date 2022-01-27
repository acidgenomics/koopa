#!/usr/bin/env bash

koopa:::install_hdf5() { # {{{1
    # """
    # Install HDF5.
    # @note Updated 2021-12-07.
    # """
    local app dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='hdf5'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa::is_macos
    then
        dict[gfortran_prefix]='/usr/local/gfortran'
        koopa::assert_is_dir "${dict[gfortran_prefix]}"
        koopa::add_to_path_start "${dict[gfortran_prefix]}/bin"
    fi
    koopa::assert_is_installed 'gfortran'
    dict[maj_min_ver]="$(koopa::major_minor_version "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://support.hdfgroup.org/ftp/HDF5/releases/\
${dict[name]}-${dict[maj_min_ver]}/${dict[name]}-${dict[version]}/\
src/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
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
