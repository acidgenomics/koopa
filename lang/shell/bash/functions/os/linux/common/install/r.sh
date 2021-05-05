#!/usr/bin/env bash

koopa::linux_install_r() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        "$@"
}

koopa::linux_install_r_devel() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        --version='devel' \
        --installer='r-devel' \
        "$@"
}

koopa:::linux_install_r() { # {{{1
    # """
    # Install R.
    # @note Updated 2021-05-04.
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - Homebrew recipe:
    #   https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # """
    local file flags jobs major_version name name2 prefix r url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='r'
    name2="$(koopa::capitalize "$name")"
    jobs="$(koopa::cpu_count)"
    major_version="$(koopa::major_version "$version")"
    file="${name2}-${version}.tar.gz"
    url="https://cloud.r-project.org/src/base/${name2}-${major_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
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

koopa:::linux_install_r_devel() { # {{{1
    # """
    # Install R-devel.
    # @note Updated 2021-05-04.
    # """
    local flags jobs name prefix repo_url revision rtop
    koopa::assert_is_linux
    koopa::assert_is_installed svn
    prefix="${INSTALL_PREFIX:?}"
    name='r-devel'
    jobs="$(koopa::cpu_count)"
    # Subversion revision number (e.g. 80130).
    revision="$(koopa::variable "$name")"
    # Set the R source code repo URL.
    repo_url='https://svn.r-project.org/R'
    # Set the desired top-level directory structure.
    rtop="${PWD}/svn/r"
    # Create necessary build directories.
    koopa::mkdir "${rtop}/${name}/build"
    # Check out the latest revision of R-devel.
    koopa::cd "$rtop"
    svn checkout \
        --revision="$revision" \
        "${repo_url}/trunk" \
        "${name}/source"
    # Ensure that repo is up-to-date.
    # > koopa::cd "${rtop}/${name}/source"
    # > svn update
    # Get the sources of the recommended packages.
    koopa::cd "${rtop}/${name}/source/tools"
    ./rsync-recommended
    # Ready to build from source.
    koopa::cd "${rtop}/${name}/build"
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
    r="${prefix}/bin/R"
    koopa::assert_is_file "$r"
    koopa::configure_r "$r"
    return 0
}
