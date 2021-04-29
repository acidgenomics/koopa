#!/usr/bin/env bash

install_r_devel() { # {{{1
    # """
    # Install R-devel.
    # @note Updated 2021-04-28.
    # """
    local flags jobs prefix repo_url revision rtop
    koopa::assert_is_linux
    koopa::assert_is_installed svn
    prefix="${INSTALL_PREFIX:?}"
    jobs="$(koopa::cpu_count)"
    # Subversion revision number (e.g. 80130).
    revision="$(koopa::variable 'r-devel')"
    # Set the R source code repo URL.
    repo_url='https://svn.r-project.org/R'
    # Set the desired top-level directory structure.
    rtop="${PWD}/svn/r"
    # Create necessary build directories.
    koopa::mkdir "${rtop}/r-devel/build"
    # Check out the latest revision of R-devel.
    koopa::cd "$rtop"
    svn checkout \
        --revision="$revision" \
        "${repo_url}/trunk" \
        'r-devel/source'
    # Ensure that repo is up-to-date.
    # > koopa::cd "${rtop}/r-devel/source"
    # > svn update
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
    r="${prefix}/bin/R"
    koopa::assert_is_file "$r"
    koopa::configure_r "$r"
    return 0
}

install_r_devel "$@"
