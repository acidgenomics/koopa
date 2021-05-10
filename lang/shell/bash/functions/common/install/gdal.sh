#!/usr/bin/env bash

koopa::install_gdal() { # {{{1
    koopa::install_app \
        --name='gdal' \
        --name-fancy='GDAL' \
        "$@"
}

koopa:::install_gdal() { # {{{1
    # """
    # Install GDAL.
    # @note Updated 2021-05-10.
    #
    # Use 'configure --help' for build options.
    #
    # If you don't need python support you can suppress it at configure using
    # '--without-python'.
    #
    # Use OpenJPEG instead of Jasper.
    # This is particularly important for CentOS builds.
    # - https://github.com/OSGeo/gdal/issues/2402
    # - https://github.com/OSGeo/gdal/issues/1708
    # """
    local brew_opt_pkgs conf_args file jobs name opt_pkgs prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='gdal'
    conf_args=(
        "--prefix=${prefix}"
        '--with-openjpeg'
        '--with-python=python3'
        '--without-jasper'
    )
    opt_pkgs=('geos' 'proj')
    if koopa::is_linux
    then
        # This approach assumes that geos, proj, python, and sqlite are
        # symlinked into the make prefix.
        opt_pkgs+=('python' 'sqlite')
        # > local make_prefix
        # > make_prefix="$(koopa::make_prefix)"
        # > conf_args+=(
        # >    --with-proj="$make_prefix" \
        # >    --with-sqlite3="$make_prefix" \
        # >    CFLAGS="-I${make_prefix}/include" \
        # >    CPPFLAGS="-I${make_prefix}/include" \
        # >    LDFLAGS="-L${make_prefix}/lib"
        # > )
    elif koopa::is_macos
    then
        brew_opt_pkgs=('sqlite')
        koopa::activate_homebrew_opt_prefix "${brew_opt_pkgs[@]}"
        koopa::macos_activate_python
    fi
    koopa::activate_opt_prefix "${opt_pkgs[@]}"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::alert_coffee_time
    ./configure "${conf_args[@]}"
    # Use '-d' flag for more verbose debug mode.
    make --jobs="$jobs"
    make install
    return 0
}
