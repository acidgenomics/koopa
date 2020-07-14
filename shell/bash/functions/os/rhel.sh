#!/usr/bin/env bash

koopa::rhel_enable_epel() { # {{{1
    koopa::assert_has_no_args "$#"
    if sudo dnf repolist | grep -q 'epel/'
    then
        koopa::success 'EPEL is already enabled.'
        return 0
    fi
    sudo dnf install -y \
        'https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm'
    return 0
}

koopa::rhel_install_base() { # {{{1
    # """
    # Install Red Hat Enterprise Linux (RHEL) base system.
    # @note Updated 2020-07-14.
    #
    # Note that RHEL 8+ now uses dnf instead of yum.
    # """
    local dev extra name_fancy pkgs
    koopa::assert_is_installed dnf sudo
    dev=1
    extra=1
    koopa::is_docker && extra=0
    # Install Fedora base first.
    koopa::fedora_install_base "$@"
    name_fancy='Red Hat Enterprise Linux (RHEL) base system'
    koopa::install_start "$name_fancy"

    # Default {{{2
    # --------------------------------------------------------------------------

    koopa::h2 'Installing default packages.'
    # 'dnf-plugins-core' installs 'config-manager'.
    sudo dnf -y install dnf-plugins-core util-linux-user
    sudo dnf config-manager --set-enabled PowerTools
    koopa::rhel_enable_epel

    # Developer {{{2
    # --------------------------------------------------------------------------

    if [[ "$dev" -eq 1 ]]
    then
        koopa::h2 "Installing developer libraries."
        pkgs=('libgit2' 'libssh2')
        sudo dnf -y install "${pkgs[@]}"
    fi

    # Extra {{{2
    # --------------------------------------------------------------------------

    if [[ "$extra" -eq 1 ]]
    then
        koopa::h2 "Installing extra recommended packages."
        sudo dnf -y install python3
    fi

    koopa::install_success "$name_fancy"
    return 0
}

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
    pro=0
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --pro)
                pro=1
                shift 1
                ;;
            --reinstall)
                reinstall=1
                shift 1
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
    koopa::assert_is_installed R
    name='rstudio-server'
    name_fancy='RStudio Server'
    if [[ "$pro" -eq 1 ]]
    then
        name="${name}-pro"
        name_fancy="${name_fancy} Pro"
        file="rstudio-server-rhel-pro-${version}-x86_64.rpm"
    else
        file="rstudio-server-rhel-${version}-x86_64.rpm"
    fi
    version="$(koopa::variable "$name")"
    name_fancy="${name_fancy} ${version}"
    ! koopa::is_current_version "$name" && reinstall=1
    [[ "$reinstall" -eq 0 ]] && koopa::exit_if_installed "$name"
    koopa::install_start "$name_fancy"
    if koopa::is_rhel_8
    then
        os_id='fedora28'
    else
        koopa::stop 'Unsupported RHEL/CentOS version.'
    fi
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        url="https://download2.rstudio.org/server/${os_id}/x86_64/${file}"
        koopa::download "$url"
        sudo yum -y install "$file"
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

koopa::rhel_install_rstudio_server_pro() {
    koopa::rhel_install_rstudio_server --pro "$@"
    return 0
}

