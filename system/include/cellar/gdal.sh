#!/usr/bin/env bash

# Install GDAL.
# Updated 2019-07-26.

# This requires PROD 6+.

# See also:
# - https://gdal.org/
# - https://github.com/OSGeo/GDAL
# - https://trac.osgeo.org/gdal/wiki/BuildingOnUnix
# - https://github.com/OSGeo/gdal/issues/1352
# - https://gis.stackexchange.com/questions/317109

# FIXME This still isn't working correctly, due to ldconfig issue.
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_alter_name'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `H5P_CLS_DATASET_CREATE_ID_g'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_eckert_i'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_miller_cylindrical'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_trans_generic'
# [...]
# collect2: error: ld returned 1 exit status

_koopa_assert_has_no_environments
_koopa_assert_is_installed proj

name="gdal"
version="$(koopa variable "$name")"
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
    ## Use `configure --help` for build options.
    ##
    ## If you don't need python support you can suppress it at configure using
    ## `--without-python`.
    CPPFLAGS="-I${build_prefix}/include" \
        LDFLAGS="-L${build_prefix}/lib" \
        ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --with-proj="$build_prefix" \
        --with-python="python3"
    make
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
