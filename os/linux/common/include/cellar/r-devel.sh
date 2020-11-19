#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::assert_is_linux
koopa::assert_is_installed svn
# Set the R source code repo URL.
repos='https://svn.r-project.org/R'
# Set the desired top-level directory structure.
rtop="${PWD}/svn/r"
# Create necessary build directories.
koopa::mkdir "${rtop}/r-devel/build"
# Check out the latest revision of R-devel.
koopa::cd "$rtop"
svn co "${repos}/trunk" 'r-devel/source'
# Ensure that repo is up-to-date.
# > koopa::cd "${rtop}/r-devel/source"
# > svn up
# Get the sources of the recommended packages.
koopa::cd "${rtop}/r-devel/source/tools"
./rsync-recommended
# Ready to build from source.
koopa::cd "${rtop}/r-devel/build"
# Use the same flags as 'install-r' script.
flags=(
    "--prefix=${prefix}"
    '--enable-R-profiling'
    '--enable-R-shlib'
    '--enable-memory-profiling'
    '--with-blas'
    '--with-cairo'
    '--with-jpeglib'
    '--with-lapack'
    '--with-readline'
    '--with-tcltk'
    '--with-x=no'
)
# We build in the separate directory created above,
# in order not to pollute the source code.
../source/configure "${flags[@]}"
make --jobs="$jobs"
make check
make pdf
make info
make install
