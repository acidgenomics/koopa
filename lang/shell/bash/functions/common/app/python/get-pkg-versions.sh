#!/usr/bin/env bash

koopa::python_get_pkg_versions() {
    # """
    # Get pinned Python package versions for pip install call.
    # @note Updated 2021-10-05.
    # """
    local i pkg pkgs pkg_lower version
    koopa::assert_has_args "$#"
    pkgs=("$@")
    for i in "${!pkgs[@]}"
    do
        # FIXME Rework this using dict approach.
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa::lowercase "$pkg")"
        version="$(koopa::variable "python-${pkg_lower}")"
        pkgs[$i]="${pkg}==${version}"
    done
    koopa::print "${pkgs[@]}"
    return 0
}
