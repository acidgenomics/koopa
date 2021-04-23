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

koopa::macos_install_r_devel() { # {{{1
    # """
    # Install R-devel on macOS.
    # @note Updated 2021-03-25.
    # """
    local arch file macos_version name_fancy r_version tmp_dir url
    koopa::assert_has_no_args "$#"
    arch="$(koopa::arch)"
    r_version='devel'
    macos_version='el-capitan'
    tmp_dir="$(koopa::tmp_dir)"
    name_fancy="R-${r_version} for ${macos_version}."
    koopa::install_start "$name_fancy"
    koopa::alert_note 'Debian r-devel inside a Docker container is preferred.'
    (
        koopa::cd "$tmp_dir"
        file="R-${r_version}-${macos_version}-sa-${arch}.tar.gz"
        url="https://mac.r-project.org/${macos_version}/R-${r_version}/${file}"
        koopa::download "$url"
        if [[ -d '/Library/Frameworks/R.framework' ]] &&
            [[ ! -L '/Library/Frameworks/R.framework' ]]
        then
            koopa::alert_note "Backing up existing 'R.framework'."
            koopa::mv -S \
                '/Library/Frameworks/R.framework' \
                '/Library/Frameworks/R.framework.bak'
        fi
        sudo tar -xzvf "$file" -C /
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    # Create versioned symlinks.
    koopa::mv -S \
        '/Library/Frameworks/R.framework' \
        "/Library/Frameworks/R-${r_version}.framework"
    koopa::ln -S \
        "/Library/Frameworks/R-${r_version}.framework" \
        '/Library/Frameworks/R.framework'
    koopa::update_r_config
    koopa::install_success "$name_fancy"
    koopa::alert_note "Ensure that 'R_LIBS_USER' in '~/.Renviron' is correct."
    return 0
}

koopa::macos_install_r_sf() { # {{{1
    # """
    # Install R sf package.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa::is_r_package_installed sf && return 0
    Rscript -e "\
        install.packages(
            pkgs = \"sf\",
            type = \"source\",
            configure.args = paste(
                \"--with-gdal-config=/usr/local/opt/gdal/bin/gdal-config\",
                \"--with-geos-config=/usr/local/opt/geos/bin/geos-config\",
                \"--with-proj-data=/usr/local/opt/proj/share/proj\",
                \"--with-proj-include=/usr/local/opt/proj/include\",
                \"--with-proj-lib=/usr/local/opt/proj/lib\",
                \"--with-proj-share=/usr/local/opt/proj/share\"
            )
        )"
    return 0
}

koopa::macos_install_r_units() { # {{{1
    # """
    # Install R units package.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa::is_r_package_installed units && return 0
    Rscript -e "\
        install.packages(
            pkgs = \"units\",
            type = \"source\",
            configure.args = c(
                \"--with-udunits2-lib=/usr/local/lib\",
                \"--with-udunits2-include=/usr/include/udunits2\"
            )
        )"
    return 0
}

koopa::macos_install_r_xml() { # {{{1
    # """
    # Install R XML package.
    # @note Updated 2020-07-16.
    #
    # Note that CRAN recommended clang7 compiler doesn't currently work.
    # CC='/usr/local/clang7/bin/clang'
    # > brew info gcc
    # > brew info libxml2
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa::is_r_package_installed XML && return 0
    Rscript -e "\
        install.packages(
            pkgs = \"XML\",
            type = \"source\",
            configure.vars = c(
                \"CC=/usr/local/opt/gcc/bin/gcc-9\",
                \"XML_CONFIG=/usr/local/opt/libxml2/bin/xml2-config\"
            )
        )"
    return 0
}

