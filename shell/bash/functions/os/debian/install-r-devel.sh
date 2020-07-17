#!/usr/bin/env bash

koopa::debian_install_r_devel() {
    # """
    # Install latest version of R-devel from CRAN.
    # @note Updated 2020-07-16.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    #
    # The following NEW packages will be installed:
    # - bison
    # - ca-certificates-java
    # - default-jdk
    # - default-jdk-headless
    # - default-jre
    # - default-jre-headless
    # - java-common
    # - libasound2
    # - libasound2-data
    # - libbison-dev
    # - libpcsclite1
    # - mpack
    # - openjdk-11-jdk
    # - openjdk-11-jdk-headless
    # - openjdk-11-jre
    # - openjdk-11-jre-headless
    # - preview-latex-style
    # - texlive-extra-utils
    # - texlive-fonts-extra
    # - texlive-latex-extra
    # - texlive-pictures
    # - texlive-plain-generic
    # - xvfb
    # """
    koopa::apt_add_r_repo
    koopa::apt_get build-dep r-base
    koopa::install_cellar \
        --name='r' \
        --name-fancy='R' \
        --version='devel' \
        --script-name='r-devel' \
        "$@"
    return 0
}
