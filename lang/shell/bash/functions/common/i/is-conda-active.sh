#!/usr/bin/env bash

koopa_is_conda_active() {
    # """
    # Is there a Conda environment active?
    # @note Updated 2023-01-10.
    # """
    [[ -n "${CONDA_DEFAULT_ENV:-}" ]]
}
