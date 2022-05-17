#!/usr/bin/env bash

koopa_cpu_count() {
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2022-04-06.
    # """
    local app num
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [nproc]="$(koopa_locate_nproc --allow-missing)"
    )
    if koopa_is_installed "${app[nproc]}"
    then
        num="$("${app[nproc]}")"
    elif koopa_is_macos
    then
        app[sysctl]="$(koopa_macos_locate_sysctl)"
        num="$("${app[sysctl]}" -n 'hw.ncpu')"
    elif koopa_is_linux
    then
        app[getconf]="$(koopa_linux_locate_getconf)"
        num="$("${app[getconf]}" '_NPROCESSORS_ONLN')"
    else
        num=1
    fi
    koopa_print "$num"
    return 0
}
