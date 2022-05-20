#!/usr/bin/env bash

koopa_python_get_pkg_versions() {
    # """
    # Get pinned Python package versions for pip install call.
    # @note Updated 2022-01-20.
    # """
    local i pkg pkgs pkg_lower version
    koopa_assert_has_args "$#"
    pkgs=("$@")
    for i in "${!pkgs[@]}"
    do
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa_lowercase "$pkg")"
        version="$(koopa_variable "python-${pkg_lower}")"
        pkgs[$i]="${pkg}==${version}"
    done
    koopa_print "${pkgs[@]}"
    return 0
}
