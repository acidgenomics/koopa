#!/usr/bin/env bash

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-11-11.
    # """
    local koopa_prefix script
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa_prefix="$(koopa::prefix)"
    export KOOPA_FORCE=1
    set +u
    # shellcheck disable=SC1090
    . "${koopa_prefix}/activate"
    set -u
    script="$(koopa::prefix)/lang/r/include/check-system.R"
    koopa::assert_is_file "$script"
    Rscript --vanilla "$script"
    koopa::check_exports
    koopa::check_disk
    koopa::check_data_disk
    return 0
}
