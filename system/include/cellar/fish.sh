#!/usr/bin/env bash
set -Eeu -o pipefail

# https://github.com/fish-shell/fish-shell/#building

# RHEL 7 build warning:
# checking the doxygen version... 1.8.5
# configure: WARNING: doxygen version 1.8.5 found, but 1.8.7 required

# Seeing a 'make test' error pop up on RHEL 7:
# cd tests; ../test/root/bin/fish interactive.fish
# Testing interactive functionality
# Tests disabled: `expect` not found
# make: *** [test_interactive] Error 1

name="fish"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."


(
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="fish-3.0.2.tar.gz"
    url="https://github.com/fish-shell/fish-shell/releases/download/${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "fish-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    # Disable testing (see error above)
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
_koopa_update_shells "$name"

command -v "$exe_file"
"$exe_file" --version

# > fish_config
# > fish_update_completions
