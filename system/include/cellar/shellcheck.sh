#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-shellcheck [--help|-h]

Install ShellCheck.

see also:
    - Install ShellCheck from source
      https://github.com/koalaman/shellcheck#compiling-from-source
    - Install GHC and cabal-install from source
      https://www.haskell.org/downloads/linux/

note:
    Bash script.
    Updated 2019-09-23.
EOF
}

_koopa_help "$@"

name="shellcheck"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    url="https://storage.googleapis.com/shellcheck/shellcheck-v${version}.linux.x86_64.tar.xz"
    wget -qO- "$url" | tar -xJv
    mkdir -pv "${prefix}/bin"
    cp "shellcheck-v${version}/shellcheck" "${prefix}/bin"
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
