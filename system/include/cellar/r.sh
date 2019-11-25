#!/usr/bin/env bash
set -Eeu -o pipefail

# Need to improve this:
# > _koopa_update_r_config
# > _koopa_r_javareconf
# > sudo: R: command not found

_koopa_assert_is_installed java javac tex

name="r"
version="$(_koopa_variable "$name")"
minor_version="$(echo "$version" | cut -d "." -f 1)"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing R ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="R-${version}.tar.gz"
    url="https://cran.r-project.org/src/base/R-${minor_version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "R-${version}" || exit 1
    # R will warn if R_HOME environment variable is set.
    unset -v R_HOME
    # Fix for reg-tests-1d.R error, due to unset TZ variable.
    # https://stackoverflow.com/questions/46413691
    export TZ="America/New_York"
    ./configure \
        --build="$build" \
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
    make --jobs="$jobs"
    make check
    make install
    rm -fr "$tmp_dir"
)

# We need to run this first to pick up R_HOME correctly.
_koopa_link_cellar "$name" "$version"

_koopa_update_r_config

# Run again to ensure R site config files propagate correctly.
_koopa_link_cellar "$name" "$version"
