#!/usr/bin/env bash

koopa::install_r_devel() { # {{{1
    koopa::install_app \
        --name='r-devel' \
        --name-fancy='R-devel' \
        "$@"
}

koopa:::install_r_devel() { # {{{1
    # """
    # Install R-devel.
    # @note Updated 2021-05-27.
    # """
    local flags jobs make name prefix repo_url revision rtop
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'svn'
    fi
    koopa::assert_is_installed 'svn'
    prefix="${INSTALL_PREFIX:?}"
    revision="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='r-devel'
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
    # > koopa::cd "${rtop}/${name}/source"
    # Draft version information is located in 'VERSION' file.
    # How to ensure that repo is up-to-date.
    # > svn update
    # Here's how to switch to a different revision inside the source trunk.
    # Somewhere between 80100 and 80200 the version was changed.
    # > svn checkout \
    # >     --revision='80190' \
    # >     "${repo_url}/trunk" \
    # >     .
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
    "$make" --jobs="$jobs"
    "$make" check
    "$make" pdf
    "$make" info
    "$make" install
    r="${prefix}/bin/R"
    koopa::assert_is_file "$r"
    koopa::configure_r "$r"
    return 0
}
