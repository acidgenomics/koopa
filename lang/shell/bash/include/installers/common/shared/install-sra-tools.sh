#!/usr/bin/env bash

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2022-06-22.
    #
    # @seealso
    # - https://github.com/ncbi/sra-tools/wiki/
    # - https://github.com/ncbi/ncbi-vdb
    # - https://github.com/ncbi/ngs-tools
    # - https://hpc.nih.gov/apps/sratoolkit.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/sratoolkit.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'hdf5' 'libxml2' 'python'
    # Need to use HDF5 1.10 API.
    export CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    [[ -x "${app[cmake]}" ]] || return 1
    declare -A dict=(
        [base_url]='https://github.com/ncbi'
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    # Build NCBI VDB Software Development Kit.
    dict[name]='ncbi-vdb'
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="${dict[base_url]}/${dict[name]}/archive/refs/tags/\
${dict[version]}.tar.gz"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    "${app[cmake]}" \
        -S "${dict[name]}-${dict[version]}" \
        -B "${dict[name]}-${dict[version]}-build" \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[cmake]}" --build "${dict[name]}-${dict[version]}-build"
    dict[ncbi_vdb_build]="$( \
        koopa_realpath "${dict[name]}-${dict[version]}-build" \
    )"
    dict[ncbi_vdb_source]="$( \
        koopa_realpath "${dict[name]}-${dict[version]}" \
    )"
    # Build and install NCBI SRA Toolkit.
    dict[name]='sra-tools'
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="${dict[base_url]}/${dict[name]}/archive/refs/tags/\
${dict[version]}.tar.gz"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    "${app[cmake]}" \
        -S "${dict[name]}-${dict[version]}" \
        -B "${dict[name]}-${dict[version]}-build" \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}" \
        -DVDB_BINDIR="${dict[ncbi_vdb_build]}" \
        -DVDB_INCDIR="${dict[ncbi_vdb_source]}/interfaces" \
        -DVDB_LIBDIR="${dict[ncbi_vdb_build]}/lib"
    "${app[cmake]}" --build "${dict[name]}-${dict[version]}-build"
    "${app[cmake]}" --install "${dict[name]}-${dict[version]}-build"

    # FIXME Install NCBI NGS Toolkit.
    # > dict[url]="${dict[base_url]}/ngs-tools/archive/refs/tags/${dict[file]}"

    return 0
}
