#!/usr/bin/env bash

koopa::debian_install_r_cran_binary() { # {{{1
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2021-04-29.
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/README.html
    # """
    local name_fancy pkgs r version
    r='/usr/bin/R'
    koopa::is_installed "$r" && return 0
    while (("$#"))
    do
        case "$1" in
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "${version:-}" ]] && version="$(koopa::variable r)"
    name_fancy="R CRAN ${version} binary package"
    koopa::install_start "$name_fancy"
    # This ensures we're starting fresh with the correct apt repo.
    koopa::rm -S \
        '/etc/R' \
        '/etc/apt/sources.list.d/r.list' \
        '/usr/lib/R/etc'
    koopa::apt_add_r_repo "$version"
    pkgs=('r-base' 'r-base-dev')
    koopa::apt_install "${pkgs[@]}"
    # Ensure we don't have a duplicate site library.
    koopa::rm -S '/usr/local/lib/R'
    koopa::configure_r
    koopa::install_success "$name_fancy"
    return 0
}

# FIXME This is now erroring out in our Ubuntu Docker image.
koopa::debian_install_r_devel() { # {{{1
    # """
    # Install latest version of R-devel from CRAN.
    # @note Updated 2021-05-11.
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
    koopa::install_r_devel "$@"
    return 0
}

koopa::debian_uninstall_r_cran_binary() { # {{{1
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2020-07-16.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='R CRAN binary'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::rm -S '/etc/R' '/usr/lib/R/etc'
    koopa::apt_remove 'r-*'
    koopa::uninstall_success "$name_fancy"
    return 0
}
