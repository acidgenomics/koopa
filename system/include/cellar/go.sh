#!/usr/bin/env bash
set -Eeu -o pipefail

name="go"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"

_koopa_message "Installing ${name} ${version}."

_koopa_prefix_mkdir "$prefix"

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="go${version}.linux-amd64.tar.gz"
    url="https://dl.google.com/go/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    # Move only the 'bin/' directory.
    mv -v go/bin "${prefix}/."
    rm -fr "$tmp_dir"
)

_koopa_prefix_chgrp "$prefix"
_koopa_link_cellar "$name" "$version"

# > fish_config
# > fish_update_completions
