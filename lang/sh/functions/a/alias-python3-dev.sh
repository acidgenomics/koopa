#!/bin/sh

_koopa_alias_python3_dev() {
    # """
    # Python development alias that sets PYTHONPATH to working directory.
    # @note Updated 2024-04-19.
    # """
    PYTHONPATH="$(pwd)" python3
}
