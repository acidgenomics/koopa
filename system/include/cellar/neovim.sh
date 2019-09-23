#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-neovim [--help|-h]

Install Neovim.

CMAKE_BUILD_TYPE:
    - Release: Full compiler optimisations and no debug information. Expect the
      best performance from this build type. Often used by package maintainers.
    - Debug: Full debug information; little optimisations. Use this for
      development to get meaningful output from debuggers like gdb or lldb. This
      is the default, if CMAKE_BUILD_TYPE is not specified.
    - RelWithDebInfo ("Release With Debug Info"): Enables many optimisations and
      adds enough debug info so that when nvim ever crashes, you can still get a
      backtrace.

see also:
    - https://neovim.io/
    - https://github.com/neovim/neovim
    - https://github.com/neovim/neovim/wiki/Installing-Neovim
    - https://github.com/neovim/neovim/wiki/Building-Neovim

note:
    Bash script.
    Updated 2019-09-17.
EOF
}

_koopa_help "$@"

_koopa_assert_has_no_environments

name="neovim"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/nvim"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/${name}/${name}/archive/v${version}.tar.gz"
    tar -xzvf "v${version}.tar.gz"
    cd "${name}-${version}" || exit 1
    make \
        --jobs="$CPU_COUNT" \
        CMAKE_BUILD_TYPE=Release \
        CMAKE_INSTALL_PREFIX="$prefix"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
"$exe_file" --version
command -v "$exe_file"
