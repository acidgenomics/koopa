#!/usr/bin/env bash

koopa:::debian_install_r_devel() { # {{{1
    # """
    # Install latest version of R-devel from CRAN.
    # @note Updated 2022-01-25.
    #
    # @seealso
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://github.com/rocker-org/rocker/blob/
    #       dd592d5c3ab289f33bf06c6c84eda354ddc40a38/r-devel/Dockerfile
    # - https://github.com/geerlingguy/ansible-role-java/issues/64
    # """
    local app conf_args dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_key]="$(koopa::debian_locate_apt_key)"
        [make]="$(koopa::locate_make)"
        [sudo]="$(koopa::locate_sudo)"
        [svn]="$(koopa::locate_svn)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='r-devel'
        [prefix]="${INSTALL_PREFIX:?}"
        [revision]="${INSTALL_VERSION:?}"
        [svn_url]='https://svn.r-project.org/R/trunk'
        [rtop]="$(koopa::init_dir 'svn/r')"
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
    # FIXME Quote these and detab upon success.
    koopa::debian_apt_install \
		bash-completion \
		bison \
		debhelper \
		default-jdk \
		g++ \
		gcc \
		gdb \
		gfortran \
		groff-base \
		libblas-dev \
		libbz2-dev \
		libcairo2-dev/unstable \
		libcurl4-openssl-dev \
		libjpeg-dev \
		liblapack-dev \
		liblzma-dev \
		libncurses5-dev \
		libpango1.0-dev \
		libpcre3-dev \
		libpng-dev \
		libreadline-dev \
		libtiff5-dev \
		libx11-dev \
		libxt-dev \
		mpack \
		subversion \
		tcl8.6-dev \
		texinfo \
		texlive-base \
		texlive-extra-utils \
		texlive-fonts-extra \
		texlive-fonts-recommended \
		texlive-generic-recommended \
		texlive-latex-base \
		texlive-latex-extra \
		texlive-latex-recommended \
		tk8.6-dev \
		x11proto-core-dev \
		xauth \
		xdg-utils \
		xfonts-base \
		xvfb \
		zlib1g-dev
    "${app[svn]}" checkout \
        --revision="${dict[revision]}" \
        "${dict[svn_url]}" \
        "${dict[rtop]}"
    koopa::cd "${dict[rtop]}"
    export TZ='America/New_York'
    unset -v R_HOME
    koopa::activate_openjdk
    ./configure "${conf_args[@]}"
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
