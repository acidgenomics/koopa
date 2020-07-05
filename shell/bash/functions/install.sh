#!/usr/bin/env bash

koopa::install_pip() { # {{{1
    # """
    # Install pip for Python.
    # @note Updated 2020-02-10.
    # """
    local file python
    python="${1:-python3}"
    if ! koopa::is_installed "$python"
    then
        koopa::warning "Python ('${python}') is not installed."
        return 1
    fi
    if koopa::is_python_package_installed --python="$python" 'pip'
    then
        koopa::note 'pip is already installed.'
        return 0
    fi
    koopa::install_start 'pip'
    file='get-pip.py'
    koopa::download "https://bootstrap.pypa.io/${file}"
    "$python" "$file" --no-warn-script-location
    rm "$file"
    koopa::install_success 'pip'
    koopa::restart
    return 0
}

