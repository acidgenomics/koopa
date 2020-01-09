#!/usr/bin/env bash
set -Eeu -o pipefail

# https://github.com/junegunn/fzf/blob/master/BUILD.md

name="fzf"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
make_prefix="$(_koopa_make_prefix)"
opt_prefix="${make_prefix}/opt/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

rm -frv "$prefix" "$opt_prefix"
mkdir -pv "$prefix" "$opt_prefix"

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="${version}.tar.gz"
    _koopa_download "https://github.com/junegunn/fzf/archive/${file}"
    _koopa_extract "$file"
    cd "${name}-${version}" || exit 1
    # Build fzf binary for your platform in 'target/'.
    make --jobs="$jobs"
    make test
    # This will copy fzf binary from 'target/' to 'bin/' inside tmp dir.
    # Note that this step does not copy to '/usr/bin/'.
    make install
    # > ./install --help
    ./install --bin --no-update-rc
    # Following approach used in Homebrew recipe here.
    rm -fr src target
    # Install into opt prefix and then link essential directories.
    cp -irv . "$opt_prefix"
    rm -fr "$tmp_dir"
)

_koopa_set_permissions "$opt_prefix"

_koopa_message "Linking 'bin' and 'man' directories from 'opt' into 'cellar'."
cp -frsv \
    "${opt_prefix}/"{bin,man} \
    "${prefix}/."

_koopa_message "Linking 'plugin' and 'shell' directories in 'opt'."
ln -fnsv \
    "${opt_prefix}/"{plugin,shell} \
    "$(dirname "$opt_prefix")/."

_koopa_link_cellar "$name" "$version"
