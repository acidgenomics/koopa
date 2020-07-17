#!/usr/bin/env bash

koopa::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2020-07-17.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local name_fancy pkgs prefix python x
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    python="$(koopa::python)"
    koopa::exit_if_not_installed "$python"
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    x="$("$python" -m pip list --outdated --format='freeze')"
    x="$(koopa::print "$x" | grep -v '^\-e')"
    if [[ -z "$x" ]]
    then
        koopa::success 'All Python packages are current.'
        return 0
    fi
    prefix="$(koopa::python_site_packages_prefix)"
    readarray -t pkgs <<< "$(koopa::print "$x" | cut -d '=' -f 1)"
    koopa::dl 'Packages' "$(koopa::to_string "${pkgs[@]}")"
    koopa::dl 'Prefix' "$prefix"
    "$python" -m pip install --no-warn-script-location --upgrade "${pkgs[@]}"
    koopa::is_cellar "$python" && koopa::link_cellar python
    koopa::install_success "$name_fancy"
    return 0
}

