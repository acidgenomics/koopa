#!/usr/bin/env bash

koopa::macos_install_r_cran_gfortran() { # {{{1
    # """
    # Install CRAN gfortran.
    # @note Updated 2021-04-22.
    # @seealso
    # - https://mac.r-project.org/tools/
    # - https://github.com/fxcoudert/gfortran-for-macOS/
    # """
    local file name os_codename pkg prefix reinstall stem tmp_dir url version
    # This is compatible with Catalina and Big Sur for 8.2. May need to rework
    # the variable handling for this in a future update.
    os_codename='Mojave'
    reinstall=0
    version="$(koopa::variable 'r-cran-gfortran')"
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
    name='gfortran'
    prefix="/usr/local/${name}"
    [[ "$reinstall" -eq 1 ]] && koopa::rm -S "$prefix"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "${name} already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name" "$version" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        stem="${name}-${version}-${os_codename}"
        file="${stem}.dmg"
        url="https://mac.r-project.org/tools/${file}"
        koopa::download "$url"
        hdiutil mount "$file"
        pkg="/Volumes/${stem}/${stem}/gfortran.pkg"
        sudo installer -pkg "$pkg" -target /
        hdiutil unmount "/Volumes/${stem}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name" "$prefix"
    koopa::alert_restart
    return 0
}
