#!/usr/bin/env bash

# RHEL 7 dependencies
# file-devel : libmagic
# > sudo yum -y install \
# >     file-devel \
# >     libhdf5-devel \
# >     libxml2-devel

# ncbi-vdb will fail to install unless we extract the tarballs to the same
# top level directory without version numbers.
# ## required ngs-sdk package not found.
# https://github.com/ncbi/sra-tools/issues/48

# > sudo ldconfig -v
# > export LD_LIBRARY_PATH=/usr/local/lib64

_acid_assert_is_installed jar

name="sra-tools"
version="$(_acid_variable "$name")"
build_prefix="${tmp_dir}/ncbi-outdir"
ngs_libdir="$(_acid_build_prefix)/lib64"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"

# Ensure current jar binary is in path, otherwise install will fail.
java_home="$(_acid_java_home)"

_acid_message "Installing ${name} ${version}."
_acid_add_to_path_start "${java_home}/bin"

export NGS_LIBDIR="$ngs_libdir"
export LD_LIBRARY_PATH="${NGS_LIBDIR}:${LD_LIBRARY_PATH}"

rm -frv "$prefix"
rm -fr "$tmp_dir"
mkdir -p "$tmp_dir"



# ngs                                                                       {{{1
# ==============================================================================

(
    cd "$tmp_dir" || exit 1
    file="ngs.tar.gz"
    url="https://github.com/ncbi/ngs/archive/${version}.tar.gz"
    _acid_download "$url" "$file"
    _acid_extract "$file"
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

_acid_link_cellar "$name" "$version"



# ncbi-vdb                                                                  {{{1
# ==============================================================================

(
    cd "$tmp_dir" || exit 1
    file="ncbi-vdb.tar.gz"
    url="https://github.com/ncbi/ncbi-vdb/archive/${version}.tar.gz"
    _acid_download "$url" "$file"
    _acid_extract "$file"
    mv "ncbi-vdb-${version}" "ncbi-vdb"
    cd "ncbi-vdb" || exit 1
    ./configure \
        --build-prefix="$build_prefix" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_acid_link_cellar "$name" "$version"



# sra-tools                                                                 {{{1
# ==============================================================================

(
    cd "$tmp_dir" || exit 1
    file="sra-tools.tar.gz"
    url="https://github.com/ncbi/sra-tools/archive/${version}.tar.gz"
    _acid_download "$url" "$file"
    _acid_extract "$file"
    mv "sra-tools-${version}" "sra-tools"
    cd "sra-tools" || exit 1
    ./configure \
        --build-prefix="$build_prefix" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_acid_link_cellar "$name" "$version"

rm -fr "$tmp_dir"
