#!/usr/bin/env bash

# FIXME SUPPORT OS_ID PLATFORM.
koopa::_install_rstudio_server() {
    # """
    # Install RStudio Server.
    # @note Updated 2020-07-16.
    #
    # @seealso
    # - https://rstudio.com/products/rstudio/download-commercial/
    # """
    local file install name name_fancy pos pro reinstall tmp_dir url version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed R
    pro=0
    reinstall=0
    version=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --install=*)
                install="${1#*=}"
                shift 1
                ;;
            --install)
                install="$2"
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
    name='rstudio-server'
    name_fancy='RStudio Server'
    if [[ "$pro" -eq 1 ]]
    then
        name="${name}-pro"
        name_fancy="${name_fancy} Pro"
    fi
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    name_fancy="${name_fancy} ${version}"
    ! koopa::is_current_version "$name" && reinstall=1
    [[ "$reinstall" -eq 0 ]] && koopa::exit_if_installed "$name"
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download "$url"
        file="$(basename "$url")"
        install=("$install")
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
}

# FIXME Rework and consolidate these.
# FIXME PARSE AND HANDLE PRO HERE.

koopa::debian_install_rstudio_server() {
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2020-07-16.
    #
    # @seealso
    # https://rstudio.com/products/rstudio/download-server/debian-ubuntu/
    #
    # System config:
    # /etc/rstudio
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    #
    # Docker recipes:
    # - https://hub.docker.com/r/rocker/rstudio/dockerfile
    # - https://github.com/rocker-org/rocker-versioned/tree/master/rstudio
    # """
    local file install os_codename url
    koopa::assert_is_installed R gdebi sudo
    os_codename="$(koopa::os_codename)"
    case "$os_codename" in
        buster|focal)
            os_codename='bionic'
            ;;
        bionic)
            ;;
        *)
            koopa::stop "Unsupported OS version: \"${os_codename}\"."
            ;;
    esac

    # FIXME PASS URL, CODENAME, AND AMD64 (NAME??)
    # FIXME USE PLATFORM AS THIS VARIABLE.
    file="rstudio-server-${version}-amd64.deb"
    url="https://download2.rstudio.org/server/bionic/amd64/${file}"

    # FIXME HANDLE PRO CASE
    # file="rstudio-server-pro-${version}-amd64.deb"
    # url="https://download2.rstudio.org/server/${os_codename}/amd64/${file}"

    install='sudo gdebi --non-interactive'
    koopa::_install_rstudio_server --install="$install" --url="$url"
    return 0
}

koopa::debian_install_rstudio_server_pro() {
    koopa::debian_install_rstudio_server --pro "$@"
    return 0
}

# FIXME NEED TO PARSE PRO HERE.
# FIXME NEED TO MAKE SURE '--PRO' FLAG STILL PASSES THROUGH.
# FIXME NEED TO RETHINK FILE, URL HANDLING HERE.
koopa::rhel_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on RHEL / CentOS.
    # @note Updated 2020-07-14.
    #
    # @seealso
    # - https://rstudio.com/products/rstudio/download-server/redhat-centos/
    # - https://rstudio.com/products/rstudio/download-commercial/
    #
    # System config:
    # /etc/rstudio
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    # """
    local file os_id url
    if koopa::is_rhel_8
    then
        os_id='fedora28'
    else
        koopa::stop 'Unsupported RHEL/CentOS version.'
    fi
    # FIXME CAN WE SIMPLIFY?
    if [[ "$pro" -eq 1 ]]
    then
        file="rstudio-server-rhel-pro-${version}-x86_64.rpm"
    else
        file="rstudio-server-rhel-${version}-x86_64.rpm"
    fi
    # FIXME CAN WE SIMPLIFY?
    url="https://download2.rstudio.org/server/${os_id}/x86_64/${file}"
    install='sudo yum -y install'
    koopa::_install_rstudio_server --install="$install" --url="$url"
    return 0
}

koopa::rhel_install_rstudio_server_pro() { # {{{1
    koopa::rhel_install_rstudio_server --pro "$@"
    return 0
}

