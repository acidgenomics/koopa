#!/usr/bin/env bash

koopa::debian_install_r_cran_binary() { # {{{1
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2020-07-30.
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
            --version)
                version="$2"
                shift 2
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
    koopa::update_r_config "$r"
    # Ensure we don't have a duplicate site library.
    koopa::rm -S '/usr/local/lib/R'
    koopa::install_success "$name_fancy"
    return 0
}

