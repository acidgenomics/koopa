#!/usr/bin/env bash

koopa::install_python_packages() { # {{{1
    koopa::install_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        --no-link \
        --no-prefix-check \
        --prefix="$(koopa::python_packages_prefix)" \
        "$@"
}

koopa:::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2021-09-15.
    # """
    local pkg pkg_lower pkgs version
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        pkgs=(
            'Cython'
            'black'         # homebrew
            'bpytop'        # homebrew
            'flake8'        # homebrew
            'glances'       # homebrew
            'pip'
            'pip2pi'
            'pipx'          # homebrew
            'psutil'
            'pyflakes'
            'pylint'        # homebrew
            'pynvim'
            'pytaglib'
            'pytest'
            'ranger-fm'     # homebrew
            'setuptools'
            'six'
            'wheel'
        )
        # NOTE This code is duplicated in 'python_venv_create_r_reticulate'.
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            pkg_lower="$(koopa::lowercase "$pkg")"
            version="$(koopa::variable "python-${pkg_lower}")"
            pkgs[$i]="${pkg}==${version}"
        done
    fi
    koopa::python_pip_install "${pkgs[@]}"
    # NOTE Consider listing all installed packages here.
    return 0
}

koopa::uninstall_python_packages() { # {{{1
    # """
    # Uninstall Python packages.
    # @note Updated 2021-06-14.
    # """
    koopa::uninstall_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        --no-link \
        "$@"
}

koopa::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2021-09-15.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local cut name_fancy pkgs
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    cut="$(koopa::locate_cut)"
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    pkgs="$(koopa::python_pip_outdated)"
    if [[ -z "$pkgs" ]]
    then
        koopa::alert_success 'All Python packages are current.'
        return 0
    fi
    readarray -t pkgs <<< "$( \
        koopa::print "$pkgs" \
        | "$cut" -d '=' -f 1 \
    )"
    koopa::python_pip_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}
