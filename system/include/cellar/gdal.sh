#!/usr/bin/env bash
set -Eeu -o pipefail

_koopa_assert_is_installed proj

name="gdal"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
build_prefix="$(_koopa_make_prefix)"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"
exe_file="${prefix}/bin/gdalinfo"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
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
        --build="$build" \
        --prefix="$prefix" \
        --with-proj="$build_prefix" \
        --with-python="python3"
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
