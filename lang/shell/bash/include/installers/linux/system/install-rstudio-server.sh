#!/usr/bin/env bash

# Incorrect:
# https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.02.1-461-.deb
#
# Correct:
# https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.02.1-461-amd64.deb

main() { # {{{1
    # """
    # Install RStudio Server binary.
    # @note Updated 2022-04-26.
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
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_debian_like
    then
        dict[fun]='koopa_debian_gdebi_install'
        dict[arch]="$(koopa_arch2)" # e.g 'amd64'.
        dict[distro]='bionic'
        dict[file_ext]='deb'
    elif koopa_is_fedora_like
    then
        app[fun]='koopa_fedora_dnf_install'
        dict[arch]="$(koopa_arch)" # e.g. 'x86_64'.
        dict[distro]='centos8'
        dict[file_ext]='rpm'
        dict[init_dir]='/etc/init.d'
        if [[ ! -d "${dict[init_dir]}" ]]
        then
            koopa_mkdir --sudo "${dict[init_dir]}"
        fi
    else
        koopa_stop 'Unsupported Linux distro.'
    fi
    dict[file_stem]="${dict[name]}"
    if koopa_is_fedora_like
    then
        dict[file_stem]="${dict[file_stem]}-rhel"
    fi
    dict[file]="${dict[file_stem]}-${dict[version]}-\
${dict[arch]}.${dict[file_ext]}"
    dict[url]="https://download2.rstudio.org/server/${dict[distro]}/\
${dict[arch]}/${dict[file]}"
    # Ensure '+' gets converted to '-'.
    dict[url]="$( \
        koopa_gsub \
            --fixed \
            --pattern='+' \
            --replacement='-' \
            "${dict[url]}" \
    )"
    koopa_add_to_path_start "$(koopa_dirname "${app[r]}")"
    koopa_download "${dict[url]}" "${dict[file]}"
    "${app[fun]}" "${dict[file]}"
    return 0
}
