#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
# FIXME Rework the 'install' variable approach handling here.

koopa:::linux_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server.
    # @note Updated 2022-01-27.
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
    local file install server dict pos url
    declare -A app=(
        [r]="$(koopa::locate_r)"
    )
    declare -A dict=(
        [file_ext]=''
        [install]=''
        [name]='rstudio-server'
        [os_codename]=''
        [platform]=''
        [version]=''
        [workbench]=0
    )
    pos=()
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
            # Flags ------------------------------------------------------------
           ' --pro' | \
            '--workbench')
                dict[workbench]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
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
    if [[ "${dict[workbench]}" -eq 1 ]]
    then
        dict[name]='rstudio-workbench'
    fi
    dict[file_stem]="${dict[name]}"
    if koopa::is_fedora_like
    then
        dict[file_stem]="${dict[file_stem]}-rhel"
    fi
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa::variable "${dict[name]}")"
    fi
    koopa::add_to_path_start "$(koopa::dirname "${app[r]}")"
    file="${dict[file_stem]}-${dict[version]}-\
${dict[platform]}.${dict[file_ext]}"
    server='download2.rstudio.org'
    url="https://${server}/server/${dict[os_codename]}/\
${dict[platform]}/${file}"
    # Ensure '+' gets converted to '%2B'.
    url="$(koopa::gsub '\+' '%2B' "$url")"
    koopa::download "$url" "$file"
    IFS=' ' read -r -a install <<< "${dict[install]}"
    "${install[@]}" "$file"
    if [[ "${dict[workbench]}" -eq 1 ]]
    then
        cat << END
Activate product license key (if necessary):
> sudo rstudio-server license-manager activate <product-key>

If you want to move your license of RStudio Server to another system you should
first deactivate it on the old system with the command:
> sudo rstudio-server license-manager deactivate
END
    fi
    return 0
}
