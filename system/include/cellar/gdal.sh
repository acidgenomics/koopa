#!/usr/bin/env bash

_koopa_assert_is_installed proj

name="gdal"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
build_prefix="$(_koopa_build_prefix)"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/gdalinfo"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
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

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
