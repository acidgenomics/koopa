#!/usr/bin/env bash



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
usage: install-cellar-genrich [--help|-h]

Install Genrich.

see also:
    - https://github.com/jsh58/Genrich

note:
    Bash script.
    Updated 2019-09-23.
EOF
}



# Parse arguments                                                           {{{1
# ==============================================================================

case "${1:-}" in
    "")
        ;;
    --help|-h)
        usage
        exit
        ;;
    *)
        >&2 printf "Error: Unsupported argument: '%s'\n" "$1"
        exit 1
        ;;
esac



# Script                                                                    {{{1
# ==============================================================================

_koopa_assert_has_no_environments

name="genrich"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/jsh58/Genrich/archive/v${version}.tar.gz"
    tar -xzvf "v${version}.tar.gz"
    cd "Genrich-${version}" || exit 1
    make
    mkdir -pv "${prefix}/bin"
    cp -frv Genrich "${prefix}/bin/."
    rm -rf "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
