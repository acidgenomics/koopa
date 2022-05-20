#!/usr/bin/env bash

koopa_locate_mamba_or_conda() {
    local str
    str="$(koopa_locate_mamba --allow-missing)"
    if [[ -x "$str" ]]
    then
        koopa_print "$str"
        return 0
    fi
    koopa_locate_conda --allow-missing
}
