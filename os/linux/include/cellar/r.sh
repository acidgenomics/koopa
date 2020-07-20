#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Refer to the 'Installation + Administration' manual.
#
# See also:
# - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
# - https://support.rstudio.com/hc/en-us/articles/
#       218004217-Building-R-from-source
#
# Using TeX Live 2013, we'll see this warning:
#
#     configure: WARNING: neither inconsolata.sty nor zi4.sty found: PDF
#     vignettes and package manuals will not be rendered optimally
# """

koopa::activate_openjdk
major_version="$(koopa::major_version "$version")"
file="R-${version}.tar.gz"
url="https://cloud.r-project.org/src/base/R-${major_version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "R-${version}"
# R will warn if R_HOME environment variable is set.
unset -v R_HOME
# Fix for reg-tests-1d.R error, due to unset TZ variable.
# https://stackoverflow.com/questions/46413691
export TZ='America/New_York'
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
# Need to modify BLAS configuration handling specificallly on Debian.
if ! koopa::is_debian
then
    flags+=('--enable-BLAS-shlib')
fi
./configure "${flags[@]}"
make --jobs="$jobs"
# > make check
make pdf
make info
make install
if [[ "$link_cellar" -eq 1 ]]
then
    # Update R configuration.
    r_exe="${prefix}/bin/R"
    koopa::update_r_config "$r_exe"
fi
