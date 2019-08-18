#!/usr/bin/env bash

# Install GDAL.
# Updated 2019-07-27.

# This requires PROD 6+.

# See also:
# - https://gdal.org/
# - https://github.com/OSGeo/GDAL
# - https://trac.osgeo.org/gdal/wiki/BuildingOnUnix
# - https://github.com/OSGeo/gdal/issues/1352
# - https://gis.stackexchange.com/questions/317109
# - https://github.com/johntruckenbrodt/pyroSAR/blob/master/pyroSAR/install/install_deps.sh

_koopa_assert_has_no_environments
_koopa_assert_is_installed proj

name="gdal"
version="$(_koopa_variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
build_prefix="$(koopa build-prefix)"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/gdalinfo"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
    wget "$url"
    tar -xzvf "$file"
    cd "${name}-${version}" || exit 1
    # Use `configure --help` for build options.
    #     # If you don't need python support you can suppress it at configure using
    # `--without-python`.
    CPPFLAGS="-I${build_prefix}/include" \
        LDFLAGS="-L${build_prefix}/lib" \
        ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --with-proj="$build_prefix" \
        --with-python="python3"
    make --jobs="$CPU_COUNT"
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
