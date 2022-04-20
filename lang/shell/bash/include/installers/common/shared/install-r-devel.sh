#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install latest version of R-devel from CRAN.
    # @note Updated 2022-04-20.
    #
    # Recommended Debian packages (for Dockerfile):
    # - 'bash-completion'
    # - 'bison'
    # - 'debhelper'
    # - 'default-jdk'
    # - 'g++'
    # - 'gcc'
    # - 'gdb'
    # - 'gfortran'
    # - 'groff-base'
    # - 'libblas-dev'
    # - 'libbz2-dev'
    # - 'libcairo2-dev'
    # - 'libcurl4-openssl-dev'
    # - 'libjpeg-dev'
    # - 'liblapack-dev'
    # - 'liblzma-dev'
    # - 'libncurses5-dev'
    # - 'libpango1.0-dev'
    # - 'libpcre3-dev'
    # - 'libpng-dev'
    # - 'libreadline-dev'
    # - 'libtiff5-dev'
    # - 'libx11-dev'
    # - 'libxt-dev'
    # - 'mpack'
    # - 'subversion'
    # - 'tcl8.6-dev'
    # - 'texinfo'
    # - 'texlive-base'
    # - 'texlive-extra-utils'
    # - 'texlive-fonts-extra'
    # - 'texlive-fonts-recommended'
    # - 'texlive-latex-base'
    # - 'texlive-latex-extra'
    # - 'texlive-latex-recommended'
    # - 'tk8.6-dev'
    # - 'x11proto-core-dev'
    # - 'xauth'
    # - 'xdg-utils'
    # - 'xfonts-base'
    # - 'xvfb'
    # - 'zlib1g-dev'
    #
    # @seealso
    # - https://hub.docker.com/r/rocker/r-devel/dockerfile
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://svn.r-project.org/R/trunk/Makefile.in
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    # Consider requiring:
    # - 'openblas'
    # - 'tcl-tk'
    koopa_activate_opt_prefix \
        'curl' \
        'gettext' \
        'icu4c' \
        'lapack' \
        'libffi' \
        'libjpeg-turbo' \
        'libpng' \
        'pcre2' \
        'pkg-config' \
        'readline' \
        'texinfo' \
        'xz'
    # FIXME Need to improve openjdk install consistency.
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
        [svn]="$(koopa_locate_svn)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [revision]="${INSTALL_VERSION:?}"
        [rtop]="$(koopa_init_dir 'svn/r')"
        [svn_url]='https://svn.r-project.org/R/trunk'
        [trust_cert]='unknown-ca,cn-mismatch,expired,not-yet-valid,other'
    )
    conf_args=(
        # > '--without-blas'
        "--prefix=${dict[prefix]}"
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--program-suffix=dev'
        '--with-jpeglib'
        '--with-lapack'
        '--with-readline'
        '--with-x=no'
        '--without-recommended-packages'
    )
    if koopa_is_macos
    then
        conf_args+=('--without-aqua')
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    "${app[svn]}" \
        --non-interactive \
        --trust-server-cert-failures="${dict[trust_cert]}" \
        checkout \
            --revision="${dict[revision]}" \
            "${dict[svn_url]}" \
            "${dict[rtop]}"
    koopa_cd "${dict[rtop]}"
    # Edge case for Makefile:107 issue.
    if koopa_is_macos
    then
        koopa_print "Revision: ${dict[revision]}" > 'SVNINFO'
    fi
    export TZ='America/New_York'
    unset -v R_HOME
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    app[r]="${dict[prefix]}/bin/R"
    koopa_assert_is_installed "${app[r]}"
    koopa_link_in_bin "${app[r]}" 'R-devel'
    koopa_configure_r "${app[r]}"
    return 0
}
