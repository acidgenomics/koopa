#!/usr/bin/env bash

main() {
    # """
    # Install RStudio Server binary.
    # @note Updated 2023-04-03.
    #
    # Don't enclose values in quotes in the conf file.
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    #
    # System config: /etc/rstudio
    #
    # @seealso
    # - https://docs.rstudio.com/rsp/installation/
    # - https://rstudio.com/products/rstudio/download-server/
    # - https://rstudio.com/products/rstudio/download-commercial/
    # Docker recipes:
    # - https://hub.docker.com/r/rocker/rstudio/dockerfile
    # - https://github.com/rocker-org/rocker-versioned/tree/master/rstudio
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['r']="$(koopa_locate_system_r --realpath)"
    [[ -x "${app['r']}" ]] || exit 1
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_debian_like
    then
        app['fun']='koopa_debian_gdebi_install'
        dict['arch']="$(koopa_arch2)" # e.g 'amd64'.
        dict['distro']="$(koopa_debian_os_codename)"
        case "${dict['distro']}" in
            'jammy')
                ;;
            *)
                dict['distro']='bionic'
                ;;
        esac
        dict['file_ext']='deb'
    elif koopa_is_fedora_like
    then
        app['fun']='koopa_fedora_dnf_install'
        dict['arch']="$(koopa_arch)" # e.g. 'x86_64'.
        dict['distro']='centos8'
        dict['file_ext']='rpm'
        dict['init_dir']='/etc/init.d'
        if [[ ! -d "${dict['init_dir']}" ]]
        then
            koopa_mkdir --sudo "${dict['init_dir']}"
        fi
    else
        koopa_stop 'Unsupported Linux distro.'
    fi
    dict['file_stem']="${dict['name']}"
    if koopa_is_fedora_like
    then
        dict['file_stem']="${dict['file_stem']}-rhel"
    fi
    dict['file']="${dict['file_stem']}-${dict['version']}-\
${dict['arch']}.${dict['file_ext']}"
    dict['url']="https://download2.rstudio.org/server/${dict['distro']}/\
${dict['arch']}/${dict['file']}"
    # Ensure '+' gets converted to '-'.
    dict['url']="$( \
        koopa_gsub \
            --fixed \
            --pattern='+' \
            --replacement='-' \
            "${dict['url']}" \
    )"
    koopa_add_to_path_start "$(koopa_dirname "${app['r']}")"
    koopa_download "${dict['url']}" "${dict['file']}"
    "${app['fun']}" "${dict['file']}"
    koopa_linux_configure_system_rstudio_server
    return 0
}
