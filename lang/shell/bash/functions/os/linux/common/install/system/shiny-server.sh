#!/usr/bin/env bash

# FIXME What's up with our arch approach here?
# FIXME Does this now work for ARM? Need to double check.
# FIXME Rework using app and dict approach.
koopa::linux_install_shiny_server() { # {{{1
    # """
    # Install Shiny Server for Linux.
    # @note Updated 2021-06-16.
    #
    # Currently Debian/Ubuntu and Fedora/RHEL are supported.
    # Currently only "amd64" (x86) architecture is supported here.
    #
    # @seealso
    # - https://www.rstudio.com/products/shiny/download-server/ubuntu/
    # - https://www.rstudio.com/products/shiny/download-server/redhat-centos/
    # """
    local arch arch2 distro file file_ext install_fun name name_fancy pos
    local r reinstall url version
    arch="$(koopa::arch)"
    r="$(koopa::locate_r)"
    case "$arch" in
        'x86_64')
            arch2='amd64'
            ;;
        *)
            arch2="$arch"
            ;;
    esac
    if koopa::is_debian_like
    then
        distro='ubuntu-14.04'
        file_ext='deb'
        install_fun='koopa::debian_install_from_deb'
    elif koopa::is_fedora_like
    then
        distro='centos7'
        file_ext='rpm'
        install_fun='koopa::debian_install_from_rpm'
    else
        koopa::stop 'Unsupported Linux distro.'
    fi
    reinstall=0
    tee="$(koopa::locate_tee)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--reinstall')
                reinstall=1
                shift 1
                ;;
            '-'*)
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
    koopa::assert_is_installed 'R'
    name='shiny-server'
    version="$(koopa::variable "$name")"
    name_fancy="Shiny Server ${version}"
    ! koopa::is_current_version "$name" && reinstall=1
    [[ "$reinstall" -eq 0 ]] && koopa::is_installed "$name" && return 0
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    if ! koopa::is_r_package_installed 'shiny'
    then
        koopa::alert 'Installing shiny R package.'
        (
            "$r" -e 'install.packages("shiny")'
        ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    fi
    (
        koopa::cd "$tmp_dir"
        file="${name}-${version}-${arch2}.${file_ext}"
        url="https://download3.rstudio.org/${distro}/${arch}/${file}"
        koopa::download "$url" "$file"
        "$install_fun" "$file"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_uninstall_shiny_server() { # {{{1
    # """
    # Uninstall Shiny Server.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_apt_remove 'shiny-server'
}
