#!/usr/bin/env bash



# Notes                                                                     {{{1
# ==============================================================================

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



# Variables                                                                 {{{1
# ==============================================================================

name="sra-tools"
version="$(_koopa_variable "$name")"
tmp_dir="$(_koopa_tmp_dir)/${name}"

build_prefix="${tmp_dir}/ncbi-outdir"
ngs_libdir="$(_koopa_build_prefix)/lib64"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install SRA toolkit.

$(_koopa_help_args)

details:
    Installs NCBI NGS language bindings (ngs) and ncbi-vdb automatically.
    This install method supports ngs-python.

see also:
    - https://github.com/ncbi/sra-tools/wiki/Building-and-Installing-from-Source
    - https://github.com/ncbi/ngs/wiki/Building-and-Installing-from-Source
    - https://github.com/ncbi/ncbi-vdb/wiki/Building-and-Installing-from-Source

note:
    Bash script.
    Updated 2019-10-08.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

# Ensure current jar binary is in path, otherwise install will fail.
java_home="$(_koopa_java_home)"
_koopa_add_to_path_start "${java_home}/bin"
_koopa_assert_is_installed jar

_koopa_message "Installing ${name} ${version}."

export NGS_LIBDIR="$ngs_libdir"
export LD_LIBRARY_PATH="${NGS_LIBDIR}:${LD_LIBRARY_PATH}"
# > ld -L$NGS_LIBDIR -lngs-sdk ...

rm -frv "$prefix"
rm -fr "$tmp_dir"
mkdir -p "$tmp_dir"

# ngs                                                                       {{{1
# ------------------------------------------------------------------------------

(
    cd "$tmp_dir" || exit 1
    wget -O "ngs.tar.gz" \
        "https://github.com/ncbi/ngs/archive/${version}.tar.gz"
    tar -xzvf "ngs.tar.gz"
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

_koopa_link_cellar "$name" "$version"

# ncbi-vdb                                                                  {{{1
# ------------------------------------------------------------------------------

(
    cd "$tmp_dir" || exit 1
    wget -O "ncbi-vdb.tar.gz" \
        "https://github.com/ncbi/ncbi-vdb/archive/${version}.tar.gz"
    tar -xzvf "ncbi-vdb.tar.gz"
    mv "ncbi-vdb-${version}" "ncbi-vdb"
    cd "ncbi-vdb" || exit 1
    ./configure \
        --build-prefix="$build_prefix" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

# sra-tools                                                                 {{{1
# ------------------------------------------------------------------------------

(
    cd "$tmp_dir" || exit 1
    wget -O "sra-tools.tar.gz" \
        "https://github.com/ncbi/sra-tools/archive/${version}.tar.gz"
    tar -xzvf "sra-tools.tar.gz"
    mv "sra-tools-${version}" "sra-tools"
    cd "sra-tools" || exit 1
    ./configure \
        --build-prefix="$build_prefix" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

rm -fr "$tmp_dir"
