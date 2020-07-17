#!/usr/bin/env bash

koopa::macos_install_r_cran_clang() {
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
    koopa::h1 "Installing ${name} ${version} to \"${prefix}\"."
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

koopa::macos_install_r_cran_clang_7() {
    koopa::macos_install_r_cran_clang --version='7.0.0'
    return 0
}

koopa::macos_install_r_cran_clang_8() {
    koopa::macos_install_r_cran_clang --version='8.0.0'
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
    # CC="/usr/local/clang7/bin/clang"
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

