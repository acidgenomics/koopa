#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install R.
    # @note Updated 2022-01-25.
    #
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - Homebrew recipe:
    #   https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name2]='R'
        [name]='r'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    dict[file]="${dict[name2]}-${dict[version]}.tar.gz"
    dict[url]="https://cloud.r-project.org/src/base/\
${dict[name2]}-${dict[maj_ver]}/${dict[file]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--with-x=no'
    )
    if koopa_is_linux
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
        if ! koopa_is_debian_like
        then
            conf_args+=('--enable-BLAS-shlib')
        fi
    elif koopa_is_macos
    then
        # fxcoudert's gfortran works more reliably than using Homebrew gcc
        # See also:
        # - https://mac.r-project.org
        # - https://github.com/fxcoudert/gfortran-for-macOS/releases
        # - https://developer.r-project.org/Blog/public/2020/11/02/
        #     will-r-work-on-apple-silicon/index.html
        # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
        dict[brew_prefix]="$(koopa_homebrew_prefix)"
        dict[brew_opt]="${dict[brew_prefix]}/opt"
        koopa_activate_homebrew_opt_prefix \
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
        koopa_activate_prefix '/usr/local/gfortran'
        koopa_add_to_path_start '/Library/TeX/texbin'
        conf_args+=(
            "--with-blas=-L${dict[brew_opt]}/openblas/lib -lopenblas"
            "--with-tcl-config=${dict[brew_opt]}/tcl-tk/lib/tclConfig.sh"
            "--with-tk-config=${dict[brew_opt]}/tcl-tk/lib/tkConfig.sh"
            '--without-aqua'
        )
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name2]}-${dict[version]}"
    export TZ='America/New_York'
    unset -v R_HOME
    koopa_activate_opt_prefix 'openjdk'
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" pdf
    "${app[make]}" info
    "${app[make]}" install
    app[r]="${dict[prefix]}/bin/R"
    koopa_assert_is_installed "${app[r]}"
    koopa_configure_r "${app[r]}"
    return 0
}
