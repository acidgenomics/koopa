#!/usr/bin/env bash

# FIXME Need to wrap this.
koopa::debian_install_r_devel() { # {{{1
    # """
    # Install latest version of R-devel from CRAN.
    # @note Updated 2021-06-14.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://github.com/geerlingguy/ansible-role-java/issues/64
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
    koopa::mkdir --sudo '/usr/share/man/man1'
    koopa::debian_apt_add_r_repo
    koopa::debian_apt_get build-dep r-base
    koopa::install_r_devel "$@"
    return 0
}
