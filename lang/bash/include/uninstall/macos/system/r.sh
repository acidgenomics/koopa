#!/usr/bin/env bash

main() {
    # """
    # Uninstall R framework binary.
    # @note Updated 2023-10-23.
    # """
    local -a rm_files
    [[ -d '/Library/Frameworks/R.framework' ]] || return 0
    rm_files=(
        '/Applications/R.app'
        '/Library/Frameworks/R.framework'
        '/opt/R'
        '/usr/local/bin/R'
        '/usr/local/bin/Rscript'
    )
    koopa_rm --sudo "${rm_files[@]}"
    koopa_macos_uninstall_system_r_gfortran
    koopa_macos_uninstall_system_r_xcode_openmp
    return 0
}
