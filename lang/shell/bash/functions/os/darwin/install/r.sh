#!/usr/bin/env bash

# FIXME Need to test 8.2 and 10.2 URL update support.
# FIXME Ensure the installer doesn't link into /usr/local.
koopa::macos_install_r_cran_gfortran() { # {{{1
    # """
    # Install CRAN gfortran.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://mac.r-project.org/tools/
    # - https://github.com/fxcoudert/gfortran-for-macOS/
    # """
    local arch file file_stem name os_codename make_prefix pkg prefix reinstall
    local tee tmp_dir url url_stem version
    koopa::assert_is_admin
    arch="$(koopa::arch)"
    make_prefix="$(koopa::make_prefix)"
    name='gfortran'
    prefix="/usr/local/${name}"
    reinstall=0
    tee="$(koopa::locate_tee)"
    version="$(koopa::variable 'r-cran-gfortran')"
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
        koopa::alert_note "${name} already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name" "$version" "$prefix"
    # Example URLs:
    # - 8.2 Mojave
    #   https://github.com/fxcoudert/gfortran-for-macOS/releases/download/
    #     8.2/gfortran-8.2-Mojave.dmg
    # - 10.2 BigSur
    #   https://github.com/fxcoudert/gfortran-for-macOS/releases/download/
    #     10.2-bigsur-intel/gfortran-10.2-BigSur-Intel.dmg
    url_stem='https://github.com/fxcoudert/gfortran-for-macOS/releases/download'
    case "$version" in
        8.2)
            os_codename='Mojave'
            file_stem="${name}-${version}-${os_codename}"
            file="${file_stem}.dmg"
            url="${url_stem}/${version}/${file}"
            pkg="/Volumes/${file_stem}/${file_stem}/${name}.pkg"
            ;;
        10.2)
            os_codename="BigSur-${arch}"
            ;;
    esac
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download "$url"
        hdiutil mount "$file"
        sudo installer -pkg "$pkg" -target /
        hdiutil unmount "/Volumes/${file_stem}"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    # Ensure the installer doesn't link outside of target prefix.
    if [[ -x "${make_prefix}/bin/gfortran" ]]
    then
        koopa::rm -S "${make_prefix}/bin/gfortran"
    fi
    koopa::install_success "$name" "$prefix"
    koopa::alert_restart
    return 0
}

# FIXME Need to add support for this.
koopa::macos_install_r_framework() { # {{{1
    # """
    # Install R framework.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://cran.r-project.org/bin/macosx/
    # - https://mac.r-project.org/tools/
    # """

    # Intel:
    # https://cran.r-project.org/bin/macosx/base/R-4.1.0.pkg
    # Important: this release uses Xcode 12.4 and GNU Fortran 8.2. If you wish
    # to compile R packages from sources, you may need to download GNU Fortran
    # 8.2 - see the tools directory.

    # ARM:
    # https://cran.r-project.org/bin/macosx/big-sur-arm64/base/R-4.1.0-arm64.pkg
    # This release uses Xcode 12.4 and experimental GNU Fortran 11 arm64 fork.
    # If you wish to compile R packages from sources, you may need to download
    # GNU Fortran for arm64 from https://mac.R-project.org/libs-arm64. Any
    # external libraries and tools are expected to live in /opt/R/arm64 to not
    # conflict with Intel-based software and this build will not use /usr/local
    # to avoid such conflicts. 
    return 0
}

koopa::macos_uninstall_r_framework() { # {{{1
    # """
    # Uninstall R framework.
    # @note Updated 2021-05-21.
    # """
    local name_fancy
    name_fancy='R framework'
    koopa::uninstall_start "$name_fancy"
    koopa::rm -S \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    koopa::uninstall_success "$name_fancy"
    return 0
}

