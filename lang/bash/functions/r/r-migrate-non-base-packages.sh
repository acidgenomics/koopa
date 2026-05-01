#!/usr/bin/env bash

_koopa_r_migrate_non_base_packages() {
    # """
    # Migrate non-base (i.e. "recommended") packages from R system library
    # to site library.
    # @note Updated 2024-03-08.
    # """
    local -A app
    local -a pkgs
    _koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    readarray -t pkgs <<< "$( \
        _koopa_r_system_packages_non_base "${app['r']}"
    )"
    _koopa_is_array_non_empty "${pkgs[@]:-}" || return 0
    _koopa_alert 'Migrating non-base packages to site library.'
    _koopa_dl 'Packages' "$(_koopa_to_string "${pkgs[@]}")"
    # FIXME This doesn't seem to be erroring on warning as expected.
    _koopa_r_install_packages_in_site_library "${app['r']}" "${pkgs[@]}"
    # FIXME This doesn't seem to be erroring on warning as expected.
    _koopa_r_remove_packages_in_system_library "${app['r']}" "${pkgs[@]}"
    return 0
}
