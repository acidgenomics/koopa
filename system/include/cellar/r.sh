#!/usr/bin/env bash



# Variables                                                                 {{{1
# ==============================================================================

name="r"
version="$(_koopa_variable "$name")"
major_version="$(echo "$version" | cut -d "." -f 1)"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/R"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install R.

$(_koopa_help_args)

see also:
    - https://www.r-project.org/
    - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    - https://community.rstudio.com/t/compiling-r-from-source-in-opt-r/14666
    - https://superuser.com/questions/841270/installing-r-on-rhel-7
    - https://github.com/rstudio/rmarkdown/issues/359
    - http://pj.freefaculty.org/blog/?p=315

note:
    Bash script.
    Updated 2019-09-30.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

_koopa_assert_is_installed java
_koopa_assert_is_installed javac
_koopa_assert_is_installed tex

_koopa_message "Installing R ${version}."

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://cran.r-project.org/src/base/R-${major_version}/R-${version}.tar.gz"
    _koopa_extract "R-${version}.tar.gz"
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
        --with-x=no
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

# We need to run this first to pick up R_HOME correctly.
_koopa_link_cellar "$name" "$version"

_koopa_update_r_config

# Run again to ensure R site config files propagate correctly.
_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
