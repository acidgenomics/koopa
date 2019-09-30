#!/usr/bin/env bash



# Variables                                                                 {{{1
# ==============================================================================

name="rmate"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install rmate.

$(_koopa_help_args)

details:
    For use with Remote VSCode extension.

see also:
    - https://medium.com/@prtdomingo/
          editing-files-in-your-linux-virtual-machine-made-a-lot-easier-with-
          remote-vscode-6bb98d0639a4

note:
    Bash script.
    Updated 2019-09-30.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/aurora/rmate/archive/v${version}.tar.gz"
    tar -xzvf "v${version}.tar.gz"
    cd "rmate-${version}" || exit 1
    chmod a+x rmate
    cp rmate "${prefix}/bin"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
