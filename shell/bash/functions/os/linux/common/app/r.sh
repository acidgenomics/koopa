#!/usr/bin/env bash

koopa::linux_install_r_geos() { # {{{1
    # """
    # Install R rgeos package.
    # @note Updated 2020-07-30.
    # """
    koopa::is_r_package_installed rgeos && return 0
    koopa::assert_is_installed Rscript
    koopa::assert_is_not_file /usr/bin/geos-config
    Rscript --vanilla -e "\
        install.packages(
            pkgs = \"rgeos\",
            type = \"source\",
            repos = \"https://cran.rstudio.com\",
            configure.args = paste(
                \"--with-geos-config=/usr/local/bin/geos-config\"
            )
        )"
    return 0
}

koopa::linux_install_r_sf() { # {{{1
    # """
    # Install R sf package.
    # @note Updated 2020-07-30.
    # """
    local gdal_prefix geos_prefix make_prefix pkg_config_arr proj_prefix
    koopa::is_r_package_installed sf && return 0
    koopa::assert_is_installed Rscript
    koopa::assert_is_not_file \
        '/usr/bin/gdal-config' \
        '/usr/bin/geos-config' \
        '/usr/bin/proj'
    # How to enable versioned support, if necessary.
    # > cellar_prefix="$(koopa::cellar_prefix)"
    # > gdal_version="$(koopa::variable 'gdal')"
    # > gdal_prefix="${cellar_prefix}/gdal/${gdal_version}"
    # > geos_version="$(koopa::variable 'geos')"
    # > geos_prefix="${cellar_prefix}/geos/${geos_version}"
    # > proj_version="$(koopa::variable 'proj')"
    # > proj_prefix="${cellar_prefix}/proj/${proj_version}"
    make_prefix="$(koopa::make_prefix)"
    gdal_prefix="$make_prefix"
    geos_prefix="$make_prefix"
    proj_prefix="$make_prefix"
    pkg_config_arr=(
        "${gdal_prefix}/lib/pkgconfig"
        "${proj_prefix}/lib/pkgconfig"
        '/usr/local/lib/pkgconfig'
    )
    PKG_CONFIG_PATH="$(koopa::paste0 "${pkg_config_arr[@]}")"
    export PKG_CONFIG_PATH
    koopa::dl PKG_CONFIG_PATH "$PKG_CONFIG_PATH"
    koopa::dl 'gdal config' "$(pkg-config --libs gdal)"
    koopa::dl 'geos config' "$(geos-config --libs)"
    koopa::dl 'proj config' "$(pkg-config --libs proj)"
    Rscript --vanilla -e "\
        install.packages(
            pkgs = \"sf\",
            type = \"source\",
            repos = \"https://cran.rstudio.com\",
            configure.args = paste(
                \"--with-gdal-config=${gdal_prefix}/bin/gdal-config\",
                \"--with-geos-config=${geos_prefix}/bin/geos-config\",
                \"--with-proj-data=${proj_prefix}/share/proj\",
                \"--with-proj-include=${proj_prefix}/include\",
                \"--with-proj-lib=${proj_prefix}/lib\",
                \"--with-proj-share=${proj_prefix}/share\"
            )
        )"
    return 0
}

