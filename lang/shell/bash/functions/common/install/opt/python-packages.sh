#!/usr/bin/env bash

koopa::install_python_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa:::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2021-10-05.
    # """
    local pkgs
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        # Install essential defaults first.
        pkgs=(
            'pip'
            'setuptools'
            'wheel'
        )
        readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
        koopa::python_pip_install "${pkgs[@]}"
        # Now we can install additional recommended extras.
        pkgs=(
            'Cython'
            'black'         # homebrew
            'bpytop'        # homebrew
            'flake8'        # homebrew
            'glances'       # homebrew
            'pip2pi'
            'pipx'          # homebrew
            'psutil'
            'pyflakes'
            'pylint'        # homebrew
            'pynvim'
            'pytaglib'      # Failed to install on Python 3.10.
            'pytest'
            'ranger-fm'     # homebrew
            'six'
        )
    fi
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    koopa::python_pip_install "${pkgs[@]}"
    return 0
}

koopa::uninstall_python_packages() { # {{{1
    # """
    # Uninstall Python packages.
    # @note Updated 2021-06-14.
    # """
    koopa:::uninstall_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        --no-link \
        "$@"
}

koopa::update_python_packages() { # {{{1
    koopa:::update_app \
        --name='python-packages' \
        --name-fancy='Python packages'
}

koopa:::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2021-09-15.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local cut pkgs
    koopa::assert_has_no_args "$#"
    cut="$(koopa::locate_cut)"
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
    return 0
}
