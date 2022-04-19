#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install R.
    # @note Updated 2022-04-19.
    #
    # @section gfortran configuration on macOS:
    #
    # fxcoudert's gfortran works more reliably than using Homebrew gcc
    # See also:
    # - https://mac.r-project.org
    # - https://github.com/fxcoudert/gfortran-for-macOS/releases
    # - https://developer.r-project.org/Blog/public/2020/11/02/
    #     will-r-work-on-apple-silicon/index.html
    # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
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
    # Consider requiring:
    # - 'lapack'
    # - 'libffi'
    # - 'libpng'
    # - 'openblas'
    # - 'readline'
    # - 'tcl-tk'
    koopa_activate_opt_prefix \
        'curl' \
        'gettext' \
        'icu4c' \
        'jpeg' \
        'pcre2' \
        'pkg-config' \
        'texinfo' \
        'xz'
    if koopa_is_linux
    then
        # Consider migrating to Adoptium Temuring LTS in the future.
        koopa_activate_opt_prefix 'openjdk'
    elif koopa_is_macos
    then
        # We're using Adoptium Temurin LTS on macOS.
        koopa_activate_prefix '/usr/local/gfortran'
        koopa_add_to_path_start '/Library/TeX/texbin'
    fi
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    dict[file]="R-${dict[version]}.tar.gz"
    dict[url]="https://cloud.r-project.org/src/base/\
R-${dict[maj_ver]}/${dict[file]}"
    conf_args=(
        # > '--with-blas'
        # > '--with-cairo'
        # > '--with-jpeglib'
        # > '--with-lapack'
        # > '--with-readline'
        # > '--with-tcltk'
        "--prefix=${dict[prefix]}"
        '--disable-nls'
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--with-recommended-packages'
        '--with-x=no'
    )
    if koopa_is_linux
    then
        # Need to modify BLAS configuration handling specificallly on Debian.
        if ! koopa_is_debian_like
        then
            conf_args+=('--enable-BLAS-shlib')
        fi
    elif koopa_is_macos
    then
        conf_args+=('--without-aqua')
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "R-${dict[version]}"
    export TZ='America/New_York'
    unset -v R_HOME
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
