#!/usr/bin/env bash



# Variables                                                                 {{{1
# ==============================================================================

name="git"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/${name}"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install Git SCM.

$(_koopa_help_args)

details:
    The compilation settings here are from the Git SCM book website.
    Refer also to INSTALL file for details.

    This currently fails if OpenSSL v1.1.1+ is installed to '/usr/local'.
    Instead, compile Git to use the system OpenSSL in '/bin/'.

see also:
    - https://git-scm.com/
    - https://github.com/git/git
    - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
    - https://github.com/git/git/blob/master/INSTALL
    - https://github.com/progit/progit2/blob/master/book/01-introduction/
          sections/installing.asc

note:
    Bash script.
    Updated 2019-09-30.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

_koopa_assert_is_installed docbook2x-texi

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/git/git/archive/v${version}.tar.gz"
    _koopa_extract "v${version}.tar.gz"
    cd "git-${version}" || exit 1
    make configure
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --with-openssl="/bin/openssl"
    # This is now erroring on RHEL 7.7:
    # > make --jobs="$CPU_COUNT" all doc info
    # > make install install-doc install-html install-info
    make --jobs="$CPU_COUNT"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
