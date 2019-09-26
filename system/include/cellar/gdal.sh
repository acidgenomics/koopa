#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-gdal [--help|-h]

Install GDAL.

details:
    This recipe requires PROD 6+.
    Install the cellar version of that first, if necessary.

see also:
    - https://gdal.org/
    - https://github.com/OSGeo/GDAL
    - https://trac.osgeo.org/gdal/wiki/BuildingOnUnix
    - https://github.com/OSGeo/gdal/issues/1352
    - https://gis.stackexchange.com/questions/317109
    - https://github.com/johntruckenbrodt/pyroSAR/blob/master/pyroSAR/
          install/install_deps.sh

note:
    Bash script.
    Updated 2019-09-23.
EOF
}

_koopa_help "$@"

_koopa_assert_is_installed proj

name="gdal"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
build_prefix="$(_koopa_build_prefix)"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/gdalinfo"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
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
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
