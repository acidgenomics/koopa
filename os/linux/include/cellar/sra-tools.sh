#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# ncbi-vdb will fail to install unless we extract the tarballs to the same
# top level directory without version numbers.
# ## required ngs-sdk package not found.
# https://github.com/ncbi/sra-tools/issues/48
#
# > sudo ldconfig -v
# > export LD_LIBRARY_PATH=/usr/local/lib64
# """

# Ensure current jar binary is in path, otherwise install will fail.
_koopa_assert_is_installed jar
java_home="$(_koopa_java_home)"
_koopa_add_to_path_start "${java_home}/bin"

ngs_libdir="$(_koopa_make_prefix)/lib64"
export NGS_LIBDIR="$ngs_libdir"
export LD_LIBRARY_PATH="${NGS_LIBDIR}:${LD_LIBRARY_PATH:-}"

build_prefix="${tmp_dir}/ncbi-outdir"

(
    _koopa_h2 "Installing 'ngs'."
    cd "$tmp_dir" || exit 1
    file="ngs.tar.gz"
    url="https://github.com/ncbi/ngs/archive/${version}.tar.gz"
    _koopa_download "$url" "$file"
    _koopa_extract "$file"
    mv "ngs-${version}" "ngs"
    cd "ngs" || exit 1
    ./configure \
        --build-prefix="$build_prefix" \
        --prefix="$prefix"
    # Make each of the sub-projects.
    make -C ngs-sdk
    make -C ngs-java
    make -C ngs-python
    # Install each of the sub-projects.
    make -C ngs-sdk install
    make -C ngs-java install
    make -C ngs-python install
)

[[ "$link_cellar" -eq 1 ]] && _koopa_link_cellar "$name" "$version"

(
    _koopa_h2 "Installing 'ncbi-vdb'."
    cd "$tmp_dir" || exit 1
    file="ncbi-vdb.tar.gz"
    url="https://github.com/ncbi/ncbi-vdb/archive/${version}.tar.gz"
    _koopa_download "$url" "$file"
    _koopa_extract "$file"
    mv "ncbi-vdb-${version}" "ncbi-vdb"
    cd "ncbi-vdb" || exit 1
    ./configure \
        --build-prefix="$build_prefix" \
        --prefix="$prefix"
    make --jobs="$jobs"
    make install
)

[[ "$link_cellar" -eq 1 ]] && _koopa_link_cellar "$name" "$version"

(
    _koopa_h2 "Installing 'sra-tools'."
    cd "$tmp_dir" || exit 1
    file="sra-tools.tar.gz"
    url="https://github.com/ncbi/sra-tools/archive/${version}.tar.gz"
    _koopa_download "$url" "$file"
    _koopa_extract "$file"
    mv "sra-tools-${version}" "sra-tools"
    cd "sra-tools" || exit 1
    ./configure \
        --build-prefix="$build_prefix" \
        --prefix="$prefix"
    make --jobs="$jobs"
    make install
)
