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
            '--version='*)
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
    koopa::rm --sudo \
        '/etc/R' \
        '/etc/apt/sources.list.d/r.list' \
        '/usr/lib/R/etc'
    koopa::debian_apt_add_r_repo "$version"
    pkgs=('r-base' 'r-base-dev')
    koopa::debian_apt_install "${pkgs[@]}"
    # Ensure we don't have a duplicate site library.
    koopa::rm --sudo '/usr/local/lib/R'
    koopa::configure_r
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_uninstall_r_cran_binary() { # {{{1
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2021-06-14.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='R CRAN binary'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::rm --sudo '/etc/R' '/usr/lib/R/etc'
    koopa::debian_apt_remove 'r-*'
    koopa::debian_apt_delete_repo 'r'
    koopa::uninstall_success "$name_fancy"
    return 0
}
