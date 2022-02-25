#!/usr/bin/env bash

debian_install_r_devel() { # {{{1
    # """
    # Install latest version of R-devel from CRAN.
    # @note Updated 2022-01-25.
    #
    # @seealso
    # - https://hub.docker.com/r/rocker/r-devel/dockerfile
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [svn]="$(koopa_locate_svn)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='r-devel'
        [prefix]="${INSTALL_PREFIX:?}"
        [revision]="${INSTALL_VERSION:?}"
        [svn_url]='https://svn.r-project.org/R/trunk'
        [rtop]="$(koopa_init_dir 'svn/r')"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-R-shlib'
        '--program-suffix=dev'
        '--with-readline'
        '--without-blas'
        '--without-lapack'
        '--without-recommended-packages'
    )
    koopa_debian_apt_install \
        'bash-completion' \
        'bison' \
        'debhelper' \
        'default-jdk' \
        'g++' \
        'gcc' \
        'gdb' \
        'gfortran' \
        'groff-base' \
        'libblas-dev' \
        'libbz2-dev' \
        'libcairo2-dev' \
        'libcurl4-openssl-dev' \
        'libjpeg-dev' \
        'liblapack-dev' \
        'liblzma-dev' \
        'libncurses5-dev' \
        'libpango1.0-dev' \
        'libpcre3-dev' \
        'libpng-dev' \
        'libreadline-dev' \
        'libtiff5-dev' \
        'libx11-dev' \
        'libxt-dev' \
        'mpack' \
        'subversion' \
        'tcl8.6-dev' \
        'texinfo' \
        'texlive-base' \
        'texlive-extra-utils' \
        'texlive-fonts-extra' \
        'texlive-fonts-recommended' \
        'texlive-latex-base' \
        'texlive-latex-extra' \
        'texlive-latex-recommended' \
        'tk8.6-dev' \
        'x11proto-core-dev' \
        'xauth' \
        'xdg-utils' \
        'xfonts-base' \
        'xvfb' \
        'zlib1g-dev'
    "${app[svn]}" checkout \
        --revision="${dict[revision]}" \
        "${dict[svn_url]}" \
        "${dict[rtop]}"
    koopa_cd "${dict[rtop]}"
    export TZ='America/New_York'
    unset -v R_HOME
    koopa_activate_openjdk
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    app[r]="${dict[prefix]}/bin/R"
    koopa_assert_is_installed "${app[r]}"
    koopa_configure_r "${app[r]}"
    return 0
}
