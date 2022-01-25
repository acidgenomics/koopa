#!/usr/bin/env bash

# [2022-01-25] macOS hitting this install error:
#
# configure: WARNING: neither inconsolata.sty nor zi4.sty found: PDF vignettes and package manuals will not be rendered optimally
# make[1]: Entering directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220125-104003-k6sD2z8bzY/svn/r/r-devel/build/doc/manual'
# creating RESOURCES
# creating FAQ
# creating doc/html/resources.html
# make[1]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220125-104003-k6sD2z8bzY/svn/r/r-devel/build/doc/manual'
# ERROR: not an svn checkout
# make: *** [Makefile:107: svnonly] Error 1
#
# Potentially related:
# - https://stat.ethz.ch/pipermail/r-devel/2016-May/072781.html
# - http://singmann.org/installing-r-devel-on-linux/#comment-161
#
# Maybe it's the 'rsync-recommended' step not working on macOS?

koopa:::install_r_devel() { # {{{1
    # """
    # Install R-devel.
    # @note Updated 2022-01-25.
    # """
    local app conf_args dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
        [svn]="$(koopa::locate_svn)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='r-devel'
        [prefix]="${INSTALL_PREFIX:?}"
        [repo_url]='https://svn.r-project.org/R'
        [revision]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
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
        dict[brew_prefix]="$(koopa::homebrew_prefix)"
        dict[brew_opt]="${dict[brew_prefix]}/opt"
        koopa::activate_homebrew_opt_prefix \
            'gettext' \
            'jpeg' \
            'libpng' \
            'openblas' \
            'pcre2' \
            'pkg-config' \
            'readline' \
            'tcl-tk' \
            'texinfo' \
            'xz'
        koopa::activate_prefix '/usr/local/gfortran'
        koopa::add_to_path_start '/Library/TeX/texbin'
        conf_args+=(
            "--with-blas=-L${dict[brew_opt]}/openblas/lib -lopenblas"
            "--with-tcl-config=${dict[brew_opt]}/tcl-tk/lib/tclConfig.sh"
            "--with-tk-config=${dict[brew_opt]}/tcl-tk/lib/tkConfig.sh"
            '--without-aqua'
        )
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    # Set the desired top-level directory structure.
    dict[rtop]="$(koopa::init_dir 'svn/r')"
    # Create necessary build directories.
    koopa::mkdir "${dict[rtop]}/${dict[name]}/build"
    # Check out the latest revision of R-devel.
    koopa::cd "${dict[rtop]}"
    "${app[svn]}" checkout \
        --revision="${dict[revision]}" \
        "${dict[repo_url]}/trunk" \
        "${dict[name]}/source"
    # > koopa::cd "${rtop}/${name}/source"
    # Draft version information is located in 'VERSION' file.
    # How to ensure that repo is up-to-date.
    # > "${app[svn]}" update
    # Here's how to switch to a different revision inside the source trunk.
    # Somewhere between 80100 and 80200 the version was changed.
    # > "${app[svn]}" checkout \
    # >     --revision='80190' \
    # >     "${dict[repo_url]}/trunk" \
    # >     .
    # Get the sources of the recommended packages.
    koopa::cd "${dict[rtop]}/${dict[name]}/source/tools"
    ./rsync-recommended
    # Ready to build from source.
    koopa::cd "${dict[rtop]}/${dict[name]}/build"
    export TZ='America/New_York'
    unset -v R_HOME
    koopa::activate_openjdk
    # We build in the separate directory created above,
    # in order not to pollute the source code.
    ../source/configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" pdf
    "${app[make]}" info
    "${app[make]}" install
    app[r]="${dict[prefix]}/bin/R"
    koopa::assert_is_installed "${app[r]}"
    koopa::configure_r "${app[r]}"
    return 0
}
