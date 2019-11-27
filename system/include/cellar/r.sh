#!/usr/bin/env bash
set -Eeu -o pipefail

# Need to improve this:
# > _koopa_update_r_config
# > _koopa_r_javareconf
# > sudo: R: command not found

# Ubuntu build with OpenBLAS compile errors:
#
# https://r.789695.n4.nabble.com/
#     Error-when-compiling-R-with-openblas-td4693330.html
#
# gcc -Wl,--export-dynamic -fopenmp  -L"../../lib" -L/usr/local/lib -o R.bin 
# Rmain.o  -lR -lRblas
#
# ../../lib/libR.so: undefined reference to `drot_'
# ../../lib/libR.so: undefined reference to `drotg_'
# ../../lib/libR.so: undefined reference to `dswap_'
# ../../lib/libR.so: undefined reference to `dgemm_'
# ../../lib/libR.so: undefined reference to `dnrm2_'
# ../../lib/libR.so: undefined reference to `dscal_'
# ../../lib/libR.so: undefined reference to `zgemm_'
# ../../lib/libR.so: undefined reference to `dtrsm_'
# ../../lib/libR.so: undefined reference to `daxpy_'
# ../../lib/libR.so: undefined reference to `dcopy_'
# ../../lib/libR.so: undefined reference to `dsyrk_'
# ../../lib/libR.so: undefined reference to `dasum_'
# ../../lib/libR.so: undefined reference to `ddot_'
# ../../lib/libR.so: undefined reference to `dgemv_'
#
# collect2: error: ld returned 1 exit status
# Makefile:145: recipe for target 'R.bin' failed

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
    # > make check
    make install
    rm -fr "$tmp_dir"
)

# We need to run this first to pick up R_HOME correctly.
_koopa_link_cellar "$name" "$version"

_koopa_update_r_config

# Run again to ensure R site config files propagate correctly.
_koopa_link_cellar "$name" "$version"
