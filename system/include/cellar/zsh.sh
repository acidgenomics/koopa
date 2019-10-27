#!/usr/bin/env bash



# Variables                                                                 {{{1
# ==============================================================================

name="zsh"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/zsh"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/${name}"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install Z shell.

$(_koopa_help_args)

see also:
    - http://www.zsh.org/
    - http://zsh.sourceforge.net/Arc/source.html
    - https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH

note:
    Bash script.
    Updated 2019-09-30.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://sourceforge.net/projects/zsh/files/zsh/${version}/\
zsh-${version}.tar.xz/download"
    _koopa_extract "download"
    cd "zsh-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
_koopa_update_shells "$name"

command -v "$exe_file"
"$exe_file" --version
