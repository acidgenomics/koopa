#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
koopa::python_pip_outdated() { # {{{1
    # """
    # List oudated pip packages.
    # @note Updated 2021-10-27.
    #
    # Requesting 'freeze' format will return '<pkg>==<version>'.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_list/
    # """
    local prefix python version x
    python="${1:-}"
    [[ -z "${python:-}" ]] && python="$(koopa::locate_python)"
    version="$(koopa::get_version "$python")"
    prefix="$(koopa::python_packages_prefix "$version")"
    x="$( \
        "$python" -m pip list \
            --format 'freeze' \
            --outdated \
            --path "$prefix" \
    )"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}
