#!/usr/bin/env bash

# Need to improve this:
# > _acid_update_r_config
# > _acid_r_javareconf
# > sudo: R: command not found

_acid_assert_has_no_args "$@"
_acid_assert_is_installed java javac tex

name="r"
version="$(_acid_variable "$name")"
major_version="$(echo "$version" | cut -d "." -f 1)"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/R"

_acid_message "Installing R ${version}."

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="R-${version}.tar.gz"
    url="https://cran.r-project.org/src/base/R-${major_version}/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "R-${version}" || exit 1
    # R will warn if R_HOME environment variable is set.
    unset -v R_HOME
    # Fix for reg-tests-1d.R error, due to unset TZ variable.
    # https://stackoverflow.com/questions/46413691
    export TZ="America/New_York"
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
        --with-x="no"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

# We need to run this first to pick up R_HOME correctly.
_acid_link_cellar "$name" "$version"

_acid_update_r_config

# Run again to ensure R site config files propagate correctly.
_acid_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
