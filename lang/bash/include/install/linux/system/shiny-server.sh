#!/usr/bin/env bash

main() {
    # """
    # Install Shiny Server binary.
    # @note Updated 2023-05-30.
    #
    # Currently Debian/Ubuntu and Fedora/RHEL are supported.
    # Currently only "amd64" (x86) architecture is supported here.
    #
    # @seealso
    # - https://www.rstudio.com/products/shiny/download-server/ubuntu/
    # - https://www.rstudio.com/products/shiny/download-server/redhat-centos/
    # """
    local -A app dict
    app['r']="$(_koopa_locate_system_r)"
    app['rscript']="${app['r']}script"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch)" 
    dict['arch2']="$(_koopa_arch2)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if _koopa_is_debian_like
    then
        dict['fun']='_koopa_debian_install_from_deb'
        dict['distro']='ubuntu-18.04'
        dict['file_arch']="${dict['arch2']}"
        dict['file_ext']='deb'
    elif _koopa_is_fedora_like
    then
        dict['fun']='_koopa_fedora_install_from_rpm'
        dict['distro']='centos7'
        dict['file_arch']="${dict['arch']}"
        dict['file_ext']='rpm'
    else
        _koopa_stop 'Unsupported Linux distro.'
    fi
    dict['url']="https://download3.rstudio.org/${dict['distro']}/\
${dict['arch']}/shiny-server-${dict['version']}-${dict['file_arch']}.\
${dict['file_ext']}"
    _koopa_download "${dict['url']}"
    _koopa_configure_r "${app['r']}"
    _koopa_add_to_path_end '/usr/sbin' '/sbin'
    _koopa_print_env
    "${app['rscript']}" -e 'install.packages("shiny")'
    "${dict['fun']}" "$(_koopa_basename "${dict['url']}")"
    return 0
}
