#!/usr/bin/env bash

main() {
    # """
    # Install RStudio Server binary.
    # @note Updated 2023-06-12.
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
    app['r']="$(_koopa_locate_system_r --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if _koopa_is_debian_like
    then
        dict['fun']='_koopa_debian_install_from_deb'
        dict['arch']="$(_koopa_arch2)" # e.g 'amd64'.
        dict['distro']="$(_koopa_debian_os_codename)"
        case "${dict['distro']}" in
            # Ubuntu -----------------------------------------------------------
            'jammy' | 'focal')
                ;;
            # Debian -----------------------------------------------------------
            'buster' | 'bullseye')
                dict['distro']='jammy'
                ;;
            'bookworm')
                dict['distro']='focal'
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_stop "Unsupported distro: '${dict['distro']}'."
                ;;
        esac
        dict['file_ext']='deb'
    elif _koopa_is_fedora_like
    then
        dict['fun']='_koopa_fedora_install_from_rpm'
        dict['arch']="$(_koopa_arch)" # e.g. 'x86_64'.
        dict['distro']='centos8'
        dict['file_ext']='rpm'
        dict['init_dir']='/etc/init.d'
        if [[ ! -d "${dict['init_dir']}" ]]
        then
            _koopa_mkdir --sudo "${dict['init_dir']}"
        fi
    else
        _koopa_stop 'Unsupported Linux distro.'
    fi
    dict['file_stem']='rstudio-server'
    if _koopa_is_fedora_like
    then
        dict['file_stem']="${dict['file_stem']}-rhel"
    fi
    dict['url']="https://download2.rstudio.org/server/${dict['distro']}/\
${dict['arch']}/${dict['file_stem']}-${dict['version']}-${dict['arch']}.\
${dict['file_ext']}"
    # Ensure '+' gets converted to '-'.
    dict['url']="$( \
        _koopa_gsub \
            --fixed \
            --pattern='+' \
            --replacement='-' \
            "${dict['url']}" \
    )"
    _koopa_add_to_path_start "$(_koopa_dirname "${app['r']}")"
    _koopa_add_to_path_end '/usr/sbin' '/sbin'
    _koopa_print_env
    _koopa_download "${dict['url']}"
    "${dict['fun']}" "$(_koopa_basename "${dict['url']}")"
    _koopa_linux_configure_system_rstudio_server
    return 0
}
