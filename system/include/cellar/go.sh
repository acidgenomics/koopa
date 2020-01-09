#!/usr/bin/env bash
set -Eeu -o pipefail

# RHEL package:
# - api
# - bin
# - lib
# - pkg
# - src

name="go"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
make_prefix="$(_koopa_make_prefix)"
opt_prefix="${make_prefix}/opt/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"

_koopa_message "Installing ${name} ${version}."

rm -frv "$prefix" "$opt_prefix"
mkdir -pv "$prefix" "$opt_prefix"

# > _koopa_prefix_mkdir "$prefix"

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="go${version}.linux-amd64.tar.gz"
    url="https://dl.google.com/go/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    # Copy the installation to opt (see also approach used for fzf install).
    cp -rv go/* "${opt_prefix}/."
    rm -fr "$tmp_dir"
)

_koopa_set_permissions "$opt_prefix"

_koopa_message "Linking 'bin' from 'opt' into 'cellar'."
cp -frsv \
    "${opt_prefix}/bin" \
    "${prefix}/."

_koopa_link_cellar "$name" "$version"

# Need to create directory expected by GOROOT environment variable.
# If this doesn't exist, Go will currently error.
goroot="/usr/local/go"
_koopa_message "Linking GOROOT directory at '${goroot}'."
ln -fnsv "$opt_prefix" "$goroot"
go env GOROOT
