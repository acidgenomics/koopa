#!/usr/bin/env bash

# FIXME Improve this installer by informing the user how to connect by default.

koopa:::linux_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server.
    # @note Updated 2022-01-28.
    #
    # RStudio Server Pro was renamed to Workbench in 2021-06.
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
    # - https://rstudio.com/products/rstudio/download-commercial/
    # - https://rstudio.com/products/rstudio/download-server/debian-ubuntu/
    # - https://rstudio.com/products/rstudio/download-server/redhat-centos/
    # Docker recipes:
    # - https://hub.docker.com/r/rocker/rstudio/dockerfile
    # - https://github.com/rocker-org/rocker-versioned/tree/master/rstudio
    # """
    local app dict install
    declare -A app=(
        [r]="$(koopa::locate_r)"
    )
    declare -A dict=(
        [file_ext]=''
        [install]=''
        [name]="${INSTALL_NAME:?}"
        [os_codename]=''
        [platform]=''
        [version]="${INSTALL_VERSION:?}"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file-ext='*)
                dict[file_ext]="${1#*=}"
                shift 1
                ;;
            '--file-ext')
                dict[file_ext]="${2:?}"
                shift 2
                ;;
            '--install='*)
                dict[install]="${1#*=}"
                shift 1
                ;;
            '--install')
                dict[install]="${2:?}"
                shift 2
                ;;
            '--os-codename='*)
                dict[os_codename]="${1#*=}"
                shift 1
                ;;
            '--os-codename')
                dict[os_codename]="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict[platform]="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict[platform]="${2:?}"
                shift 2
                ;;
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
    koopa::assert_is_set \
        '--file-ext' "${dict[file_ext]}" \
        '--install' "${dict[install]}" \
        '--name' "${dict[name]}" \
        '--os-codename' "${dict[os_codename]}" \
        '--platform' "${dict[platform]}" \
        '--version' "${dict[version]}"
    dict[file_stem]="${dict[name]}"
    if koopa::is_fedora_like
    then
        dict[file_stem]="${dict[file_stem]}-rhel"
    fi
    koopa::add_to_path_start "$(koopa::dirname "${app[r]}")"
    dict[file]="${dict[file_stem]}-${dict[version]}-\
${dict[platform]}.${dict[file_ext]}"
    dict[url]="https://download2.rstudio.org/server/${dict[os_codename]}/\
${dict[platform]}/${dict[file]}"
    # Ensure '+' gets converted to '-'.
    dict[url]="$(koopa::gsub '\+' '-' "${dict[url]}")"
    koopa::download "${dict[url]}" "${dict[file]}"
    IFS=' ' read -r -a install <<< "${dict[install]}"
    "${install[@]}" "${dict[file]}"
    return 0
}
