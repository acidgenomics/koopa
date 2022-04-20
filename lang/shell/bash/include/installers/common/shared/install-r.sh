#!/usr/bin/env bash

# FIXME Failing capabilities: jpeg, png, tiff, libxml, cairo

main() { # {{{1
    # """
    # Install R.
    # @note Updated 2022-04-20.
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
    # @section Recommended Debian packages (for Dockerfile):
    #
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
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
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
    koopa_activate_opt_prefix \
        'curl' \
        'gettext' \
        'icu4c' \
        'lapack' \
        'libffi' \
        'libjpeg-turbo' \
        'libpng' \
        'openblas' \
        'pcre2' \
        'pkg-config' \
        'readline' \
        'tcl-tk' \
        'texinfo' \
        'xz'
    if koopa_is_linux
    then
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
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-memory-profiling'
        '--with-blas'
        '--with-jpeglib'
        '--with-lapack'
        '--with-readline'
        '--with-tcltk'
        '--with-x=no'
    )
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        # NOTE These are required for subversion to load.
        koopa_activate_opt_prefix 'sqlite'
        app[svn]="$(koopa_locate_svn)"
        dict[rtop]="$(koopa_init_dir 'svn/r')"
        dict[svn_url]='https://svn.r-project.org/R/trunk'
        dict[trust_cert]='unknown-ca,cn-mismatch,expired,not-yet-valid,other'
        "${app[svn]}" \
            --non-interactive \
            --trust-server-cert-failures="${dict[trust_cert]}" \
            checkout \
                --revision="${dict[version]}" \
                "${dict[svn_url]}" \
                "${dict[rtop]}"
        koopa_cd "${dict[rtop]}"
        # Edge case for 'Makefile:107' issue.
        if koopa_is_macos
        then
            koopa_print "Revision: ${dict[version]}" > 'SVNINFO'
        fi
        conf_args+=(
            '--without-recommended-packages'
        )
    else
        dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
        dict[file]="R-${dict[version]}.tar.gz"
        dict[url]="https://cloud.r-project.org/src/base/\
R-${dict[maj_ver]}/${dict[file]}"
        koopa_download "${dict[url]}" "${dict[file]}"
        koopa_extract "${dict[file]}"
        koopa_cd "R-${dict[version]}"
        conf_args+=(
            '--with-recommended-packages'
        )
    fi
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
    export TZ='America/New_York'
    unset -v R_HOME
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" pdf
    "${app[make]}" info
    "${app[make]}" install
    app[r]="${dict[prefix]}/bin/R"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[r]}" "${app[rscript]}"
    koopa_configure_r "${app[r]}"
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        koopa_link_in_bin "${app[r]}" 'R-devel'
    fi
    "${app[rscript]}" -e 'capabilities()'
    return 0
}
