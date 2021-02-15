#!/usr/bin/env bash

koopa::debian_install_shiny_server() { # {{{1
    # """
    # Install Shiny Server for Debian/Ubuntu.
    # @note Updated 2021-01-19.
    # @seealso
    # https://rstudio.com/products/shiny/download-server/ubuntu/
    # """
    local name name_fancy pos reinstall version
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed R gdebi
    name='shiny-server'
    version="$(koopa::variable "$name")"
    name_fancy="Shiny Server ${version}"
    ! koopa::is_current_version "$name" && reinstall=1
    [[ "$reinstall" -eq 0 ]] && koopa::is_installed "$name" && return 0
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    if ! koopa::is_r_package_installed shiny
    then
        koopa::h2 'Installing shiny R package.'
        (
            Rscript -e 'install.packages("shiny")'
        ) 2>&1 | tee "$(koopa::tmp_log_file)"
    fi
    (
        koopa::cd "$tmp_dir"
        file="shiny-server-${version}-amd64.deb"
        url="https://download3.rstudio.org/ubuntu-14.04/x86_64/${file}"
        koopa::download "$url"
        sudo gdebi --non-interactive "$file"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

