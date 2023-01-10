#!/usr/bin/env bash

koopa_is_rstudio() {
    # """
    # Is the terminal running inside RStudio?
    # @note Updated 2023-01-10.
    # """
    [[ -n "${RSTUDIO:-}" ]]
}
