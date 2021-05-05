#!/usr/bin/env bash

# FIXME Should be able to build Python from source on macOS...
# FIXME Alternatively on macOS, 'koopa install python' should point to
# 'koopa install python-framework'.

koopa::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2021-04-30.
    # """
    local name_fancy pkg pkg_lower pkgs version
    python="$(koopa::python)"
    koopa::assert_has_no_envs
    koopa::assert_is_installed "$python"
    name_fancy='Python packages'
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        pkgs=(
            # > 'pynvim'
            'pip2pi'
            'psutil'
            'pyflakes'
            'pytaglib'
            'pytest'
            'setuptools'
            'six'
            'wheel'
        )
        if ! koopa::is_installed brew
        then
            pkgs+=(
                'black'
                'bpytop'
                'flake8'
                'pipx'
                'pylint'
                'ranger-fm'
            )
        fi
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            pkg_lower="$(koopa::lowercase "$pkg")"
            version="$(koopa::variable "python-${pkg_lower}")"
            pkgs[$i]="${pkg}==${version}"
        done
    fi
    koopa::install_start "$name_fancy"
    koopa::pip_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2021-04-30.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local name_fancy pkgs python
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    python="$(koopa::python)"
    koopa::is_installed "$python" || return 0
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    pkgs="$(koopa::pip_outdated)"
    if [[ -z "$pkgs" ]]
    then
        koopa::alert_success 'All Python packages are current.'
        return 0
    fi
    readarray -t pkgs <<< "$( \
        koopa::print "$pkgs" \
        | cut -d '=' -f 1 \
    )"
    koopa::pip_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}
