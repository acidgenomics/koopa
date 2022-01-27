#!/usr/bin/env bash

# FIXME Need to wrap this.
koopa::debian_install_r_cran_binary() { # {{{1
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2021-11-03.
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/README.html
    # """
    local dict
    declare -A dict=(
        [r]='/usr/bin/R'
        [version]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "${dict[version]}" ]] && dict[version]="$(koopa::variable 'r')"
    dict[name_fancy]="R CRAN ${dict[version]} binary package"
    if koopa::is_installed "${dict[r]}"
    then
        koopa::alert_is_installed "${dict[name_fancy]}"
        return 0
    fi
    koopa::alert_install_start "${dict[name_fancy]}"
    koopa::rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc' \
        '/usr/local/lib/R'
    koopa::debian_apt_add_r_repo "${dict[version]}"
    pkgs=('r-base' 'r-base-dev')
    koopa::debian_apt_install "${pkgs[@]}"
    koopa::configure_r "${dict[r]}"
    koopa::alert_install_success "${dict[name_fancy]}"
    return 0
}

# FIXME Need to wrap this.
koopa::debian_uninstall_r_cran_binary() { # {{{1
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2021-11-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc'
    koopa::debian_apt_remove 'r-*'
    koopa::debian_apt_delete_repo 'r'
    return 0
}
