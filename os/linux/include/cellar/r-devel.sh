#!/usr/bin/env bash
# shellcheck disable=SC2154

# Set the R source code repo URL.
repos="https://svn.r-project.org/R"
# Set the desired top-level directory structure.
rtop="${PWD}/svn/r"
# Create necessary build directories.
mkdir -pv "${rtop}/r-devel/build"
# Check out the latest revision of R-devel.
cd "$rtop" || exit 1
svn co "${repos}/trunk" "r-devel/source"
# Ensure that repo is up-to-date.
# > cd "${rtop}/r-devel/source" || exit 1
# > svn up
# Get the sources of the recommended packages.
cd "${rtop}/r-devel/source/tools" || exit 1
./rsync-recommended
# Ready to build from source.
cd "${rtop}/r-devel/build" || exit 1
# Use the same flags as 'install-r' script.
flags=(
    "--enable-R-profiling"
    "--enable-R-shlib"
    "--enable-memory-profiling"
    "--prefix=${prefix}"
    "--with-blas"
    "--with-cairo"
    "--with-jpeglib"
    "--with-lapack"
    "--with-readline"
    "--with-tcltk"
    "--with-x=no"
)
# We build in the separate directory created above,
# in order not to pollute the source code.
../source/configure "${flags[@]}"
make --jobs="$jobs"
make check
make pdf
make info
make install

if [[ "$link_cellar" -eq 1 ]]
then
    # Update R configuration.
    r_exe="${prefix}/bin/R"
    _koopa_update_r_config "$r_exe"
fi
