#!/usr/bin/env bash

# FIXME This is returning empty directory error on Debian.

koopa::configure_r() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2021-11-03.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    local dict
    koopa::assert_has_args_le "$#" 1
    declare -A dict=(
        [name_fancy]='R'
        [r]="${1:-}"
    )
    [[ -z "${dict[r]}" ]] && dict[r]="$(koopa::locate_r)"
    koopa::assert_is_installed "${dict[r]}"
    dict[r_prefix]="$(koopa::r_prefix "${dict[r]}")"
    echo 'FIXME 1'
    koopa::configure_start "${dict[name_fancy]}" "${dict[r_prefix]}"
    echo 'FIXME 2'
    koopa::assert_is_dir "${dict[r_prefix]}"
    if koopa::is_koopa_app "$r"
    then
        echo 'FIXME 3'
        koopa::sys_set_permissions --recursive "${dict[r_prefix]}"
        # Ensure that (Debian) system 'etc' directories are removed.
        dict[make_prefix]="$(koopa::make_prefix)"
        dict[etc_prefix1]="${dict[make_prefix]}/lib/R/etc"
        dict[etc_prefix2]="${dict[make_prefix]}/lib64/R/etc"
        if [[ -d "${dict[etc_prefix1]}" ]] && [[ ! -L "${dict[etc_prefix1]}" ]]
        then
            koopa::sys_rm "${dict[etc_prefix1]}"
        fi
        if [[ -d "${dict[etc_prefix2]}" ]] && [[ ! -L "${dict[etc_prefix2]}" ]]
        then
            koopa::sys_rm "${dict[etc_prefix2]}"
        fi
    else
        echo 'FIXME 4'
        koopa::sys_set_permissions --recursive "${dict[r_prefix]}/library"
    fi
    echo 'FIXME 5'
    koopa::r_link_files_into_etc "${dict[r]}"
    echo 'FIXME 6'
    koopa::r_link_site_library "${dict[r]}"
    koopa::r_javareconf "${dict[r]}"
    koopa::r_rebuild_docs "${dict[r]}"
    koopa::sys_set_permissions --recursive "${dict[r_prefix]}/site-library"
    koopa::configure_success "${dict[name_fancy]}" "${dict[r_prefix]}"
    return 0
}

koopa::install_r() { # {{{1
    koopa:::install_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

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
    koopa::assert_is_installed 'java'
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
    koopa:::uninstall_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}
