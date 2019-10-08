#!/usr/bin/env bash



# Notes                                                                     {{{1
# ==============================================================================

# sudo yum install libxml2-devel
# sudo yum install libmagic-devel
# sudo yum install libhdf5-devel



# Variables                                                                 {{{1
# ==============================================================================

name="ncbi-ngs"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"

ncbi_vdb_version="$(_koopa_variable "ncbi-vdb")"

java_home="$(_koopa_java_home)"
_koopa_add_to_path_start "$java_home"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install NCBI NGS language bindings.

$(_koopa_help_args)

see also:
    - https://github.com/ncbi/ngs/wiki/Building-and-Installing-from-Source

note:
    Bash script.
    Updated 2019-10-08.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

printf "Installing %s %s.\n" "$name" "$version"

_koopa_assert_is_installed jar

rm -frv "$prefix"
rm -fr "$tmp_dir"
mkdir -p "$tmp_dir"

# Clone ncbi-vdb repo to enable ngs-python support.
(
    cd "$tmp_dir" || exit 1
    wget -O "ncbi-vdb.tar.gz" \
        "https://github.com/ncbi/ncbi-vdb/archive/${ncbi_vdb_version}.tar.gz"
    tar -xzvf "ncbi-vdb.tar.gz"
)


# Build and install ngs.
(
    cd "$tmp_dir" || exit 1
    wget -O "ngs.tar.gz" \
        "https://github.com/ncbi/ngs/archive/${version}.tar.gz"
    tar -xzvf "ngs.tar.gz"
    cd "ngs-${version}" || exit 1

    # ./configure --help
    # '--with-ncbi-vdb-prefix' flag doesn't seem to be supported?
    # Refer to 'konfigure.perl' script for details.
    ./configure \
        --build-prefix="build" \
        --prefix="$prefix"
    # Make each of the sub-projects.
    make -C ngs-sdk
    make -C ngs-java
    make -C ngs-python
    # Install each of the sub-projects.
    make -C ngs-sdk install
    make -C ngs-java install
    # Need to install ngs-sdk and ncbi-vdb to run ngs-python.
    make -C ngs-python install

    make --jobs="$CPU_COUNT"
    make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

cat << EOF
Reload the shell.
To verify update of your environment:
- LD_LIBRARY_PATH should now have the path to your installed ngs libraries.
- CLASSPATH should now have the path to your installed ngs jar.
EOF
