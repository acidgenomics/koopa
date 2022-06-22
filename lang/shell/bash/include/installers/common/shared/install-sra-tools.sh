#!/usr/bin/env bash

# NOTE Consider requiring bison, doxygen, and flex for build environment.
# Can set doxygen with 'DOXYGEN_EXECUTABLE'.

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2022-06-22.
    #
    # @seealso
    # - https://github.com/ncbi/sra-tools/wiki/
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/ncbi/ngs-tools
    # - https://hpc.nih.gov/apps/sratoolkit.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/sratoolkit.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'hdf5' 'libxml2' 'python'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    [[ -x "${app[cmake]}" ]] || return 1
    declare -A dict=(
        [base_url]='https://github.com/ncbi'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    # CMake configuration will pick up Python Framework on macOS unless we
    # set this manually.
    app[python]="$(koopa_realpath "${dict[opt_prefix]}/python/bin/python3")"
    # Need to use HDF5 1.10 API.
    export CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    # Build NCBI VDB Software Development Kit (no install).
    (
        local dict2
        declare -A dict2
        dict2[name]='ncbi-vdb'
        dict2[file]="${dict2[name]}-${dict[version]}.tar.gz"
        dict2[url]="${dict[base_url]}/${dict2[name]}/archive/refs/tags/\
${dict[version]}.tar.gz"
        koopa_download "${dict2[url]}" "${dict2[file]}"
        koopa_extract "${dict2[file]}"
        "${app[cmake]}" \
            -S "${dict2[name]}-${dict[version]}" \
            -B "${dict2[name]}-${dict[version]}-build" \
            -DCMAKE_INSTALL_PREFIX="${dict[prefix]}" \
            -DPython3_EXECUTABLE="${app[python]}"
        "${app[cmake]}" --build "${dict2[name]}-${dict[version]}-build"
    )
    dict[ncbi_vdb_build]="$( \
        koopa_realpath "ncbi-vdb-${dict[version]}-build" \
    )"
    dict[ncbi_vdb_source]="$( \
        koopa_realpath "ncbi-vdb-${dict[version]}" \
    )"
    # Build and install NCBI SRA Toolkit.
    (
        local dict2
        declare -A dict2
        dict2[name]='sra-tools'
        dict2[file]="${dict2[name]}-${dict[version]}.tar.gz"
        dict2[url]="${dict[base_url]}/${dict2[name]}/archive/refs/tags/\
${dict[version]}.tar.gz"
        koopa_download "${dict2[url]}" "${dict2[file]}"
        koopa_extract "${dict2[file]}"
        # Need to fix '/obj/ngs/ngs-java' path issue in 'CMakeLists.txt' file.
        # See related: https://github.com/ncbi/sra-tools/pull/664/files
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='/obj/ngs/ngs-java/' \
            --replacement='/ngs/ngs-java/' \
            "${dict2[name]}-${dict[version]}/ngs/ngs-java/CMakeLists.txt"
        "${app[cmake]}" \
            -S "${dict2[name]}-${dict[version]}" \
            -B "${dict2[name]}-${dict[version]}-build" \
            -DCMAKE_INSTALL_PREFIX="${dict[prefix]}" \
            -DPython3_EXECUTABLE="${app[python]}" \
            -DVDB_BINDIR="${dict[ncbi_vdb_build]}" \
            -DVDB_INCDIR="${dict[ncbi_vdb_source]}/interfaces" \
            -DVDB_LIBDIR="${dict[ncbi_vdb_build]}/lib"
        "${app[cmake]}" --build "${dict2[name]}-${dict[version]}-build"
        "${app[cmake]}" --install "${dict2[name]}-${dict[version]}-build"
    )
    # Build and install NCBI NGS Toolkit.
    (
        local dict2
        declare -A dict2
        dict2[name]='ngs-tools'
        dict2[file]="${dict2[name]}-${dict[version]}.tar.gz"
        dict2[url]="${dict[base_url]}/${dict2[name]}/archive/refs/tags/\
${dict[version]}.tar.gz"
        koopa_download "${dict2[url]}" "${dict2[file]}"
        koopa_extract "${dict2[file]}"
        "${app[cmake]}" \
            -S "${dict2[name]}-${dict[version]}" \
            -B "${dict2[name]}-${dict[version]}-build" \
            -DCMAKE_INSTALL_PREFIX="${dict[prefix]}" \
            -DSRATOOLS_BINDIR="${dict[prefix]}" \
            -DVDB_INCDIR="${dict[ncbi_vdb_source]}/interfaces" \
            -DVDB_LIBDIR="${dict[ncbi_vdb_build]}/lib"
        "${app[cmake]}" --build "${dict2[name]}-${dict[version]}-build"
        "${app[cmake]}" --install "${dict2[name]}-${dict[version]}-build"
    )
    return 0
}
