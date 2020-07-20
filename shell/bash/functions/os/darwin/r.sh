#!/usr/bin/env bash

koopa::macos_install_r_cran_clang() { # {{{1
    # """
    # Install CRAN clang.
    # @note Updated 2020-07-17.
    # Only needed for R < 4.0.
    # """
    local file major_version name prefix tmp_dir url version
    while (("$#"))
    do
        case "$1" in
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
    name='clang'
    major_version="$(koopa::major_version "$version")"
    prefix="/usr/local/${name}${major_version}"
    koopa::exit_if_dir "$prefix"
    koopa::h1 "Installing ${name} ${version} to '${prefix}'."
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${name}-${version}.pkg"
        url="https://cran.r-project.org/bin/macosx/tools/${file}"
        koopa::download "$url"
        sudo installer -pkg "$file" -target '/'
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name"
    koopa::restart
    return 0
}

koopa::macos_install_r_cran_clang_7() { # {{{1
    koopa::macos_install_r_cran_clang --version='7.0.0'
    return 0
}

koopa::macos_install_r_cran_clang_8() { # {{{1
    koopa::macos_install_r_cran_clang --version='8.0.0'
    return 0
}

koopa::macos_install_r_cran_gfortran() { # {{{1
    # """
    # Install CRAN gfortran.
    # @note Updated 2020-07-17.
    # @seealso
    # - https://github.com/fxcoudert/gfortran-for-macOS
    # """
    local file name pkg prefix stem tmp_dir url version
    while (("$#"))
    do
        case "$1" in
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
    koopa::exit_if_dir "$prefix"
    koopa::h1 "Installing ${name} ${version} to '${prefix}'."
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        # This is compatible with Catalina.
        stem="${name}-${version}-Mojave"
        file="${stem}.dmg"
        url="https://mac.r-project.org/tools/${file}"
        koopa::download "$url"
        hdiutil mount "$file"
        pkg="/Volumes/${stem}/${stem}/gfortran.pkg"
        sudo installer -pkg "$pkg" -target /
        hdiutil unmount "/Volumes/${stem}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name"
    koopa::restart
    return 0
}

koopa::macos_install_r_cran_gfortran_8() { # {{{1
    koopa::macos_install_r_cran_gfortran --version='6.1'
    return 0
}

koopa::macos_install_r_cran_gfortran_8() { # {{{1
    koopa::macos_install_r_cran_gfortran --version='8.2'
    return 0
}

koopa::macos_install_r_devel() { # {{{1
    # """
    # Install R-devel on macOS.
    # @note Updated 2020-07-17.
    # """
    koopa::assert_has_no_args "$#"
    r_version='devel'
    macos_version='el-capitan'
    tmp_dir="$(koopa::tmp_dir)"
    name_fancy="R-${r_version} for ${macos_version}."
    koopa::install_start "$name_fancy"
    koopa::note 'Debian r-devel inside a Docker container is preferred.'
    (
        koopa::cd "$tmp_dir"
        file="R-${r_version}-${macos_version}-sa-x86_64.tar.gz"
        url="https://mac.r-project.org/${macos_version}/R-${r_version}/${file}"
        koopa::download "$url"
        if [[ -d '/Library/Frameworks/R.framework' ]] &&
            [[ ! -L '/Library/Frameworks/R.framework' ]]
        then
            koopa::note "Backing up existing 'R.framework'."
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
    koopa::install_success "$name_fancy"
    koopa::note "Ensure that 'R_LIBS_USER' in '~/.Renviron' is correct."
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

