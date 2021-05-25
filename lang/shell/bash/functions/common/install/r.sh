#!/usr/bin/env bash

koopa::install_r() { # {{{1
    koopa::install_app \
        --name='r' \
        --name-fancy='R' \
        "$@"
}

koopa::install_r_devel() { # {{{1
    koopa::install_app \
        --name='r' \
        --name-fancy='R' \
        --version='devel' \
        --installer='r-devel' \
        "$@"
}

koopa:::install_r() { # {{{1
    # """
    # Install R.
    # @note Updated 2021-05-18.
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - Homebrew recipe:
    #   https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # """
    local brew_opt brew_prefix conf_args file jobs major_version name name2
    local prefix r url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='r'
    name2="$(koopa::capitalize "$name")"
    jobs="$(koopa::cpu_count)"
    major_version="$(koopa::major_version "$version")"
    conf_args=(
        "--prefix=${prefix}"
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--with-x=no'
    )
    if koopa::is_linux
    then
        conf_args+=(
            '--disable-nls'
            '--enable-R-profiling'
            '--with-blas'
            '--with-cairo'
            '--with-jpeglib'
            '--with-lapack'
            '--with-readline'
            '--with-recommended-packages'
            '--with-tcltk'
        )
        # Need to modify BLAS configuration handling specificallly on Debian.
        if ! koopa::is_debian_like
        then
            conf_args+=('--enable-BLAS-shlib')
        fi
    elif koopa::is_macos
    then
        # fxcoudert's gfortran works more reliably than using Homebrew gcc
        # See also:
        # - https://mac.r-project.org
        # - https://github.com/fxcoudert/gfortran-for-macOS/releases
        # - https://developer.r-project.org/Blog/public/2020/11/02/
        #     will-r-work-on-apple-silicon/index.html
        # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
        brew_prefix="$(koopa::homebrew_prefix)"
        brew_opt="${brew_prefix}/opt"
        koopa::activate_homebrew_opt_prefix \
            'gettext' \
            'jpeg' \
            'libpng' \
            'openblas' \
            'pcre2' \
            'pkg-config' \
            'readline' \
            'tcl-tk' \
            'xz'
        koopa::activate_prefix '/usr/local/gfortran'
        conf_args+=(
            "--with-blas=-L${brew_opt}/openblas/lib -lopenblas"
            "--with-tcl-config=${brew_opt}/tcl-tk/lib/tclConfig.sh"
            "--with-tk-config=${brew_opt}/tcl-tk/lib/tkConfig.sh"
            '--without-aqua'
        )
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    file="${name2}-${version}.tar.gz"
    url="https://cloud.r-project.org/src/base/${name2}-${major_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    koopa::activate_openjdk
    unset -v R_HOME
    export TZ='America/New_York'
    ./configure "${conf_args[@]}"
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

koopa:::install_r_devel() { # {{{1
    # """
    # Install R-devel.
    # @note Updated 2021-05-14.
    # """
    local flags jobs name prefix repo_url revision rtop
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

koopa::install_r_cmd_check() { # {{{1
    # """
    # Install R CMD check (Rcheck) scripts for CI.
    # @note Updated 2021-03-01.
    # """
    local link_name name source_repo target_dir
    koopa::assert_has_no_args "$#"
    name='r-cmd-check'
    source_repo="https://github.com/acidgenomics/${name}.git"
    target_dir="$(koopa::local_data_prefix)/${name}"
    link_name='.Rcheck'
    koopa::install_start "$name"
    if [[ ! -d "$target_dir" ]]
    then
        koopa::alert "Downloading ${name} to '${target_dir}'."
        (
            koopa::mkdir "$target_dir"
            git clone "$source_repo" "$target_dir"
        )
    fi
    koopa::ln "$target_dir" "$link_name"
    koopa::install_success "$name"
    return 0
}

koopa::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2021-05-25.
    # """
    local name_fancy pkg_prefix
    name_fancy='R packages'
    pkg_prefix="$(koopa::r_packages_prefix)"
    koopa::install_start "$name_fancy"
    koopa::configure_r
    koopa::assert_is_dir "$pkg_prefix"
    koopa::rscript 'installRPackages' "$@"
    koopa::sys_set_permissions -r "$pkg_prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-05-25.
    # """
    local name_fancy
    name_fancy='R packages'
    pkg_prefix="$(koopa::r_packages_prefix)"
    koopa::update_start "$name_fancy"
    koopa::configure_r
    koopa::assert_is_dir "$pkg_prefix"
    koopa::rscript 'updateRPackages' "$@"
    koopa::sys_set_permissions -r "$pkg_prefix"
    koopa::update_success "$name_fancy"
    return 0
}
