#!/usr/bin/env bash

_acid_assert_has_no_args "$@"
_acid_assert_is_installed proj

name="gdal"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
build_prefix="$(_acid_build_prefix)"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/gdalinfo"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "${name}-${version}" || exit 1
    # Use 'configure --help' for build options.
    # If you don't need python support you can suppress it at configure using
    # '--without-python'.
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

_acid_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
