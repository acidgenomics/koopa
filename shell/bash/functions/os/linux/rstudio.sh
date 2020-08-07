#!/usr/bin/env bash

koopa::_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server.
    # @note Updated 2020-07-30.
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
    # - https://rstudio.com/products/rstudio/download-commercial/
    # - https://rstudio.com/products/rstudio/download-server/debian-ubuntu/
    # - https://rstudio.com/products/rstudio/download-server/redhat-centos/
    # Docker recipes:
    # - https://hub.docker.com/r/rocker/rstudio/dockerfile
    # - https://github.com/rocker-org/rocker-versioned/tree/master/rstudio
    # """
    local file file_ext file_stem install name name_fancy os_codename platform \
        pos pro reinstall server tmp_dir url version
    koopa::assert_is_installed R
    pro=0
    reinstall=0
    version=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --file-ext=*)
                file_ext="${1#*=}"
                shift 1
                ;;
            --file-ext)
                file_ext="$2"
                shift 2
                ;;
            --install=*)
                install="${1#*=}"
                shift 1
                ;;
            --install)
                install="$2"
                shift 2
                ;;
            --os-codename=*)
                os_codename="${1#*=}"
                shift 1
                ;;
            --os-codename)
                os_codename="$2"
                shift 2
                ;;
            --platform=*)
                platform="${1#*=}"
                shift 1
                ;;
            --platform)
                platform="$2"
                shift 2
                ;;
            --pro)
                pro=1
                shift 1
                ;;
            --reinstall)
                reinstall=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
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
    name='rstudio-server'
    file_stem="$name"
    koopa::is_rhel_like && file_stem="${file_stem}-rhel"
    name_fancy='RStudio Server'
    if [[ "$pro" -eq 1 ]]
    then
        file_stem="${file_stem}-pro"
        name="${name}-pro"
        name_fancy="${name_fancy} Pro"
    fi
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    name_fancy="${name_fancy} ${version}"
    ! koopa::is_current_version "$name" && reinstall=1
    [[ "$reinstall" -eq 0 ]] && koopa::is_installed "$name" && return 0
    koopa::install_start "$name_fancy"
    file="${file_stem}-${version}-${platform}.${file_ext}"
    server='download2.rstudio.org'
    url="https://${server}/server/${os_codename}/${platform}/${file}"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download "$url"
        file="$(basename "$url")"
        IFS=' ' read -r -a install <<< "$install"
        "${install[@]}" "$file"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    if [[ "$pro" -eq 1 ]]
    then
        cat << END
Activate product license key (if necessary):
> sudo rstudio-server license-manager activate <product-key>

If you want to move your license of RStudio Server to another system you should
first deactivate it on the old system with the command:
> sudo rstudio-server license-manager deactivate
END
    fi
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2020-07-16.
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    # """
    local os_codename
    os_codename="$(koopa::os_codename)"
    case "$os_codename" in
        buster|focal)
            os_codename='bionic'
            ;;
        bionic)
            ;;
        *)
            koopa::stop "Unsupported OS version: '${os_codename}'."
            ;;
    esac
    koopa::_install_rstudio_server \
        --file-ext='deb' \
        --install='sudo gdebi --non-interactive' \
        --os-codename="$os_codename" \
        --platform='amd64' \
        "$@"
    return 0
}

koopa::debian_install_rstudio_server_pro() { # {{{1
    koopa::debian_install_rstudio_server --pro "$@"
    return 0
}

koopa::rhel_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on RHEL / CentOS.
    # @note Updated 2020-08-07.
    # """
    local os_codename
    if koopa::is_rhel_8_like
    then
        os_codename='fedora28'
    else
        koopa::stop 'Unsupported OS.'
    fi
    koopa::_install_rstudio_server \
        --file-ext='rpm' \
        --install='sudo dnf -y install' \
        --os-codename="$os_codename" \
        --platform='x86_64' \
        "$@"
    return 0
}

koopa::rhel_install_rstudio_server_pro() { # {{{1
    koopa::rhel_install_rstudio_server --pro "$@"
    return 0
}

koopa::shiny_server_restart() { # {{{1
    koopa::assert_has_no_args "$#"
    sudo systemctl restart shiny-server
    return 0
}

koopa::shiny_server_start() { # {{{1
    koopa::assert_has_no_args "$#"
    sudo systemctl start shiny-server
    return 0
}

koopa::shiny_server_status() { # {{{1
    koopa::assert_has_no_args "$#"
    sudo systemctl status shiny-server
    return 0
}
