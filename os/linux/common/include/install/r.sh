#!/usr/bin/env bash

install_r() { # {{{1
    # """
    # Install R.
    # @note Updated 2021-04-29.
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - Homebrew recipe:
    #   https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # """
    local file flags jobs major_version prefix r url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    major_version="$(koopa::major_version "$version")"
    file="R-${version}.tar.gz"
    url="https://cloud.r-project.org/src/base/R-${major_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "R-${version}"
    koopa::activate_openjdk
    # R will warn if R_HOME environment variable is set.
    unset -v R_HOME
    # Fix for reg-tests-1d.R error, due to unset TZ variable.
    # https://stackoverflow.com/questions/46413691
    export TZ='America/New_York'
    flags=(
        "--prefix=${prefix}"
        '--disable-nls'
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--with-blas'
        '--with-cairo'
        '--with-jpeglib'
        '--with-lapack'
        '--with-readline'
        '--with-recommended-packages'
        '--with-tcltk'
        '--with-x=no'
    )
    # Need to modify BLAS configuration handling specificallly on Debian.
    if ! koopa::is_debian_like
    then
        flags+=('--enable-BLAS-shlib')
    fi
    ./configure "${flags[@]}"
    make --jobs="$jobs"
    # > make check
    make pdf
    make info
    make install
    r="${prefix}/bin/R"
    koopa::assert_is_file "$r"
    koopa::configure_r "$r"
    return 0
}

install_r "$@"
