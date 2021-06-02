#!/usr/bin/env bash

koopa::macos_install_r_cran_gfortran() { # {{{1
    # """
    # Install CRAN gfortran.
    # @note Updated 2021-06-02.
    # @seealso
    # - https://mac.r-project.org/tools/
    # - https://github.com/fxcoudert/gfortran-for-macOS/
    # """
    local arch file file_stem name name_fancy os_codename make_prefix pkg
    local prefix reinstall tee tmp_dir url url_stem version
    koopa::assert_is_admin
    arch="$(koopa::arch)"
    make_prefix="$(koopa::make_prefix)"
    name='gfortran'
    name_fancy="R CRAN ${name}"
    prefix="/usr/local/${name}"
    reinstall=0
    tee="$(koopa::locate_tee)"
    version="$(koopa::variable "r-cran-${name}")"
    case "$arch" in
        aarch64)
            arch='ARM'
            ;;
        x86_64)
            arch='Intel'
            ;;
        *)
            koopa::stop "Unsupported architecture: '${arch}'."
            ;;
    esac
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ "$reinstall" -eq 1 ]] && koopa::rm -S "$prefix"
    if [[ -d "$prefix" ]]
    then
        # FIXME Use 'alert_is_installed' here.
        koopa::alert_note "${name} already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$version" "$prefix"
    url_stem="https://github.com/fxcoudert/${name}-for-macOS/releases/download"
    case "$version" in
        8.2)
            # R 4.0, 4.1.
            os_codename='Mojave'
            file_stem="${name}-${version}-${os_codename}"
            file="${file_stem}.dmg"
            url="${url_stem}/${version}/${file}"
            pkg="/Volumes/${file_stem}/${file_stem}/${name}.pkg"
            ;;
        10.2)
            # Not yet used.
            os_codename="BigSur-${arch}"
            os_codename2="$(koopa::lowercase "$os_codename")"
            file_stem="${name}-${version}-${os_codename}"
            file="${file_stem}.dmg"
            url="${url_stem}/${version}-${os_codename2}/${file}"
            pkg="/Volumes/${file_stem}/${name}.pkg"
            ;;
        *)
            koopa::stop "Unsupported version: '${version}'."
    esac
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download "$url"
        hdiutil mount "$file"
        koopa::assert_is_file "$pkg"
        sudo installer -pkg "$pkg" -target /
        hdiutil unmount "/Volumes/${file_stem}"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::assert_is_dir "$prefix"
    # Ensure the installer doesn't link outside of target prefix.
    if [[ -x "${make_prefix}/bin/${name}" ]]
    then
        koopa::rm -S "${make_prefix}/bin/${name}"
    fi
    koopa::install_success "$name_fancy" "$prefix"
    koopa::alert_restart
    return 0
}

koopa::macos_uninstall_r_cran_gfortran() { # {{{1
    # """
    # Uninstall R CRAN gfortran.
    # @note Updated 2021-06-02.
    # """
    local name name_fancy prefix
    name='gfortran'
    name_fancy="R CRAN ${name}"
    prefix="/usr/local/${name}"
    if [[ ! -d "$prefix" ]]
    then
        koopa::alert_not_installed "$name_fancy"
        return 0
    fi
    koopa::uninstall_start "$name_fancy" "$prefix"
    koopa::rm -S "$prefix"
    koopa::uninstall_success "$name_fancy" "$prefix"
    return 0
}

