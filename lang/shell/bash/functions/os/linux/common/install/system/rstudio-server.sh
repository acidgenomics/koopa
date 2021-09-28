#!/usr/bin/env bash

koopa:::linux_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server.
    # @note Updated 2021-09-28.
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
    local file install server dict pos tee tmp_dir url
    declare -A dict=(
        [file_ext]=''
        [install]=''
        [name]='rstudio-server'
        [name_fancy]='RStudio Server'
        [os_codename]=''
        [platform]=''
        [reinstall]=0
        [version]=''
        [workbench]=0
    )
    koopa::assert_is_installed 'R'
    tee="$(koopa::locate_tee)"
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
            '--reinstall')
                dict[reinstall]=1
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
        dict[name_fancy]='RStudio Workbench'
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
    dict[name_fancy]="${dict[name_fancy]} ${dict[version]}"
    if ! koopa::is_current_version "${dict[name]}"
    then
        dict[reinstall]=1
    fi
    # NOTE This step may not check correctly for RStudio Workbench.
    if [[ "${dict[reinstall]}" -eq 0 ]] && koopa::is_installed "${dict[name]}"
    then
        koopa::alert_is_installed "${dict[name_fancy]}"
        return 0
    fi
    koopa::install_start "${dict[name_fancy]}"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${dict[file_stem]}-${dict[version]}-\
${dict[platform]}.${dict[file_ext]}"
        server='download2.rstudio.org'
        url="https://${server}/server/${dict[os_codename]}/\
${dict[platform]}/${file}"
        # Ensure '+' gets converted to '%2B'.
        url="$(koopa::gsub '\+' '%2B' "$url")"
        koopa::download "$url"
        file="$(basename "$url")"
        IFS=' ' read -r -a install <<< "${dict[install]}"
        "${install[@]}" "$file"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
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
    koopa::install_success "${dict[name_fancy]}"
    return 0
}

koopa::linux_add_rstudio_user() { #{{{1
    # """
    # Enable RStudio user on Linux.
    # @note Updated 2021-09-27.
    # """
    sudo useradd 'rstudio'
    sudo passwd 'rstudio'
    sudo mkdir -p '/home/rstudio'
    sudo chown 'rstudio:rstudio' '/home/rstudio'
    sudo usermod -s '/bin/bash' 'rstudio'
    return 0
}
