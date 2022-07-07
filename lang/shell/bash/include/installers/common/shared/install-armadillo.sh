#!/usr/bin/env bash

main() {
    # """
    # Install Armadillo.
    # @note Updated 2022-07-05.
    #
    # @seealso
    # - http://arma.sourceforge.net/download.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/armadillo.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'hdf5'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='armadillo'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="http://sourceforge.net/projects/arma/files/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX:PATH=${dict[prefix]}"
        '-DDETECT_HDF5=ON'
    )
    if koopa_is_macos
    then
        cmake_args+=('-DALLOW_OPENBLAS_MACOS=ON')
    fi
    "${app[cmake]}" . "${cmake_args[@]}"
    "${app[make]}" install
    return 0
}
