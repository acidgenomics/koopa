#!/usr/bin/env bash

koopa::update_venv() {
    # """
    # Update Python virtual environment.
    # @note Updated 2020-07-13.
    # """
    local array lines python
    koopa::assert_has_no_args "$#"
    python="$(koopa::python)"
    koopa::assert_is_installed "$python"
    if ! koopa::is_venv_active
    then
        koopa::note 'No active Python venv detected.'
        return 0
    fi
    koopa::h1 'Updating Python venv.'
    "$python" -m pip install --upgrade pip
    lines="$("$python" -m pip list --outdated --format='freeze')"
    readarray -t array <<< "$lines"
    koopa::is_array_non_empty "${array[@]}" || exit 0
    koopa::h1 "${#array[@]} outdated packages detected."
    koopa::print "$lines" \
        | cut -d '=' -f 1 \
        | xargs -n1 "$python" -m pip install --upgrade
    return 0
}

