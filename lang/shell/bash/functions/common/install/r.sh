#!/usr/bin/env bash


# FIXME Consider reworking these into configure script, and simplify...
koopa::link_r_etc() { # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2021-04-29.
    #
    # Don't copy Makevars file across machines.
    # """
    local distro_prefix file files r r_etc_source r_etc_target r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-$(koopa::locate_r)}"
    koopa::assert_is_installed "$r"
    r="$(koopa::which_realpath "$r")"
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::assert_is_dir "$r_prefix"
    version="$(koopa::r_version "$r")"
    if [[ "$version" != 'devel' ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    distro_prefix="$(koopa::distro_prefix)"
    r_etc_source="${distro_prefix}/etc/R/${version}"
    koopa::assert_is_dir "$r_etc_source"
    if koopa::is_linux && \
        ! koopa::is_symlinked_app "$r" && \
        [[ -d '/etc/R' ]]
    then
        # This applies to Debian/Ubuntu CRAN binary installs.
        r_etc_target='/etc/R'
    else
        r_etc_target="${r_prefix}/etc"
    fi
    files=(
        'Makevars.site'  # macOS
        'Renviron.site'
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        [[ -f "${r_etc_source}/${file}" ]] || continue
        koopa::sys_ln "${r_etc_source}/${file}" "${r_etc_target}/${file}"
    done
    return 0
}

koopa::link_r_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2021-06-11.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local lib_source lib_target r r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-$(koopa::locate_r)}"
    koopa::assert_is_installed "$r"
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::assert_is_dir "$r_prefix"
    version="$(koopa::r_version "$r")"
    lib_source="$(koopa::r_packages_prefix "$version")"
    lib_target="${r_prefix}/site-library"
    koopa::dl 'Site library' "$lib_source"
    koopa::alert "Linking '${lib_source}' into R install at '${lib_target}'."
    koopa::sys_mkdir "$lib_source"
    koopa::sys_set_permissions "$(koopa::dirname "$lib_source")"
    if [[ "$version" != 'devel' ]]
    then
        koopa::link_into_opt "$lib_source" 'r-packages'
    fi
    koopa::sys_ln "$lib_source" "$lib_target"
    if koopa::is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa::alert_note 'Fixing Fedora R configuration.'
        koopa::sys_ln \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}

koopa::r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2021-05-05.
    #
    # The default Java path differs depending on the system.
    #
    # > R CMD javareconf -h
    #
    # Environment variables that can be used to influence the detection:
    #   JAVA           path to a Java interpreter executable
    #                  By default first 'java' command found on the PATH
    #                  is taken (unless JAVA_HOME is also specified).
    #   JAVA_HOME      home of the Java environment. If not specified,
    #                  it will be detected automatically from the Java
    #                  interpreter.
    #   JAVAC          path to a Java compiler
    #   JAVAH          path to a Java header/stub generator
    #   JAR            path to a Java archive tool
    #
    # How to check that rJava works:
    # > library(rJava)
    # > .jinit()
    # """
    local java_flags java_home r r_cmd
    koopa::assert_has_args_le "$#" 1
    r="${1:-$(koopa::locate_r)}"
    koopa::assert_is_installed "$r"
    r="$(koopa::which_realpath "$r")"
    if [[ -z "${java_home:-}" ]]
    then
        koopa::activate_openjdk
        java_home="$(koopa::java_prefix)"
        if ! koopa::is_installed 'java'
        then
            koopa::alert_note "Failed to locate 'java'."
            return 0
        fi
    fi
    # This step can happen with r-devel in Docker images.
    if [[ ! -d "$java_home" ]]
    then
        koopa::alert_note "Failed to locate 'JAVA_HOME'."
        return 0
    fi
    koopa::alert 'Updating R Java configuration.'
    koopa::dl 'R' "$r"
    koopa::dl 'Java home' "$java_home"
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )
    if koopa::is_symlinked_app "$r"
    then
        r_cmd=("$r")
    else
        koopa::assert_is_admin
        r_cmd=('sudo' "$r")
    fi
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_flags[@]}"
    return 0
}

koopa::r_rebuild_docs() { # {{{1
    # """
    # Rebuild R HTML/CSS files in 'docs' directory.
    # @note Updated 2021-04-29.
    #
    # 1. Ensure HTML package index is writable.
    # 2. Touch an empty 'R.css' file to eliminate additional package warnings.
    #    Currently we're seeing this inside Fedora Docker images.
    #
    # @seealso
    # HTML package index configuration:
    # https://stat.ethz.ch/R-manual/R-devel/library/utils/html/
    #     make.packages.html.html
    # """
    local doc_dir html_dir pkg_index r rscript rscript_flags
    r="${1:-$(koopa::locate_r)}"
    rscript="${r}script"
    koopa::assert_is_installed "$r" "$rscript"
    rscript_flags=('--vanilla')
    koopa::assert_is_installed "$r" "$rscript"
    koopa::alert 'Updating HTML package index.'
    doc_dir="$("$rscript" "${rscript_flags[@]}" -e 'cat(R.home("doc"))')"
    html_dir="${doc_dir}/html"
    [[ ! -d "$html_dir" ]] && koopa::mkdir -S "$html_dir"
    pkg_index="${html_dir}/packages.html"
    koopa::dl 'HTML index' "$pkg_index"
    [[ ! -f "$pkg_index" ]] && sudo touch "$pkg_index"
    r_css="${html_dir}/R.css"
    [[ ! -f "$r_css" ]] && sudo touch "$r_css"
    koopa::sys_set_permissions "$pkg_index"
    "$rscript" "${rscript_flags[@]}" -e 'utils::make.packages.html()'
}








# FIXME Should we simplify, setting up the linkage into opt here first?
koopa::configure_r() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2021-06-13.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    local etc_prefix make_prefix name_fancy r r_prefix
    koopa::assert_has_args_le "$#" 1
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    koopa::assert_is_installed "$r"
    name_fancy='R'
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::configure_start "$name_fancy" "$r_prefix"
    koopa::dl \
        'R home' "$r_prefix" \
        'R path' "$r"
    koopa::assert_is_dir "$r_prefix"
    if koopa::is_symlinked_app "$r"
    then
        make_prefix="$(koopa::make_prefix)"
        etc_prefix="${make_prefix}/lib/R/etc"
        koopa::sys_set_permissions -r "$r_prefix"
        # Ensure that (Debian) system 'etc' directories are removed.
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            koopa::sys_rm "$etc_prefix"
        fi
        etc_prefix="${make_prefix}/lib64/R/etc"
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            koopa::sys_rm "$etc_prefix"
        fi
    else
        koopa::sys_set_permissions -r "${r_prefix}/library"
    fi
    koopa::link_r_etc "$r"
    koopa::link_r_site_library "$r"
    koopa::r_javareconf "$r"
    koopa::r_rebuild_docs "$r"
    koopa::sys_set_permissions -r "${r_prefix}/site-library"
    koopa::configure_success "$name_fancy" "$r_prefix"
    return 0
}

koopa::install_r() { # {{{1
    koopa::install_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

# Run 'koopa install tex-packages' if you hit this warning:
# neither inconsolata.sty nor zi4.sty found: PDF vignettes and package manuals
# will not be rendered optimally

koopa:::install_r() { # {{{1
    # """
    # Install R.
    # @note Updated 2021-05-26.
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - Homebrew recipe:
    #   https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # """
    local brew_opt brew_prefix conf_args file jobs major_version
    local make name name2 prefix r url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
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
            'texinfo' \
            'xz'
        koopa::activate_prefix '/usr/local/gfortran'
        koopa::add_to_path_start '/Library/TeX/texbin'
        conf_args+=(
            "--with-blas=-L${brew_opt}/openblas/lib -lopenblas"
            "--with-tcl-config=${brew_opt}/tcl-tk/lib/tclConfig.sh"
            "--with-tk-config=${brew_opt}/tcl-tk/lib/tkConfig.sh"
            '--without-aqua'
        )
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    name='r'
    name2="$(koopa::capitalize "$name")"
    major_version="$(koopa::major_version "$version")"
    file="${name2}-${version}.tar.gz"
    url="https://cloud.r-project.org/src/base/${name2}-${major_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    koopa::activate_openjdk
    unset -v R_HOME
    export TZ='America/New_York'
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" check
    "$make" pdf
    "$make" info
    "$make" install
    r="${prefix}/bin/R"
    koopa::assert_is_file "$r"
    koopa::configure_r "$r"
    return 0
}

koopa::uninstall_r() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}
