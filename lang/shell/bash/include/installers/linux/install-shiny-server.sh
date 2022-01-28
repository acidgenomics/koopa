#!/usr/bin/env bash

koopa:::linux_install_shiny_server() { # {{{1
    # """
    # Install Shiny Server for Linux.
    # @note Updated 2022-01-28.
    #
    # Currently Debian/Ubuntu and Fedora/RHEL are supported.
    # Currently only "amd64" (x86) architecture is supported here.
    #
    # @seealso
    # - https://www.rstudio.com/products/shiny/download-server/ubuntu/
    # - https://www.rstudio.com/products/shiny/download-server/redhat-centos/
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [r]="$(koopa::locate_r)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [name]='shiny-server'
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[arch]}" in
        'x86_64')
            dict[arch2]='amd64'
            ;;
        *)
            dict[arch2]="${dict[arch]}"
            ;;
    esac
    if koopa::is_debian_like
    then
        app[fun]='koopa::debian_install_from_deb'
        dict[distro]='ubuntu-14.04'
        dict[file_ext]='deb'
    elif koopa::is_fedora_like
    then
        app[fun]='koopa::debian_install_from_rpm'
        dict[distro]='centos7'
        dict[file_ext]='rpm'
    else
        koopa::stop 'Unsupported Linux distro.'
    fi
    dict[file]="${dict[name]}-${dict[version]}-${dict[arch2]}.${dict[file_ext]}"
    dict[url]="https://download3.rstudio.org/${dict[distro]}/\
${dict[arch]}/${dict[file]}"
    if ! koopa::is_r_package_installed 'shiny'
    then
        koopa::alert 'Installing shiny R package.'
        "${app[r]}" -e 'install.packages("shiny")'
    fi
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::configure_r "${app[r]}"
    "${app[fun]}" "${dict[file]}"
    return 0
}
