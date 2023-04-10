#!/usr/bin/env bash

main() {
    # """
    # Install Shiny Server binary.
    # @note Updated 2023-04-05.
    #
    # Currently Debian/Ubuntu and Fedora/RHEL are supported.
    # Currently only "amd64" (x86) architecture is supported here.
    #
    # @seealso
    # - https://www.rstudio.com/products/shiny/download-server/ubuntu/
    # - https://www.rstudio.com/products/shiny/download-server/redhat-centos/
    # """
    local -A app dict
    app['r']="$(koopa_locate_system_r)"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)" 
    dict['arch2']="$(koopa_arch2)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_debian_like
    then
        dict['fun']='koopa_debian_install_from_deb'
        dict['distro']='ubuntu-18.04'
        dict['file_arch']="${dict['arch2']}"
        dict['file_ext']='deb'
    elif koopa_is_fedora_like
    then
        dict['fun']='koopa_fedora_install_from_rpm'
        dict['distro']='centos7'
        dict['file_arch']="${dict['arch']}"
        dict['file_ext']='rpm'
    else
        koopa_stop 'Unsupported Linux distro.'
    fi
    dict['url']="https://download3.rstudio.org/${dict['distro']}/\
${dict['arch']}/shiny-server-${dict['version']}-${dict['file_arch']}.\
${dict['file_ext']}"
    koopa_download "${dict['url']}"
    koopa_configure_r "${app['r']}"
    "${app['rscript']}" -e 'install.packages("shiny")'
    "${dict['fun']}" "$(koopa_basename "${dict['url']}")"
    return 0
}
