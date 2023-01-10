#!/bin/sh

koopa_is_rstudio() {
    # """
    # Is the terminal running inside RStudio?
    # @note Updated 2020-06-19.
    # """
    [ -n "${RSTUDIO:-}" ]
}
