#!/usr/bin/env bash

# Install R.
# Updated 2019-06-25.

# See also:
# - https://www.r-project.org/
# - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
# - https://community.rstudio.com/t/compiling-r-from-source-in-opt-r/14666
# - https://superuser.com/questions/841270/installing-r-on-rhel-7
# - https://github.com/rstudio/rmarkdown/issues/359
# - http://pj.freefaculty.org/blog/?p=315

_koopa_assert_has_no_environments

name="R"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/${name}"

major_version="$(echo "$version" | cut -d "." -f 1)"
# > minor_version="$(echo "$version" | cut -d "." -f 2-)"

printf "Installing %s %s.\n" "$name" "$version"

(
    # R will warn if R_HOME environment variable is set.
    unset -v R_HOME

    # Fix for reg-tests-1d.R error, due to unset TZ variable.
    # https://stackoverflow.com/questions/46413691
    export TZ="America/New_York"

    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://cran.r-project.org/src/base/R-${major_version}/R-${version}.tar.gz"
    tar -xzvf "R-${version}.tar.gz"
    cd "R-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-BLAS-shlib \
        --enable-R-profiling \
        --enable-R-shlib \
        --enable-memory-profiling \
        --with-blas \
        --with-cairo \
        --with-jpeglib \
        --with-lapack \
        --with-readline \
        --with-tcltk \
        --with-x=no
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -rf "$tmp_dir"
)

# We need to run this first to pick up R_HOME correctly.
link-cellar "$name" "$version"

_koopa_update_r_config

# Run again to ensure R site config files propagate correctly.
link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
