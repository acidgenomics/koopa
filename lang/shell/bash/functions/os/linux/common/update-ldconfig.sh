#!/usr/bin/env bash

koopa_linux_update_ldconfig() {
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2022-01-31.
    # """
    local app dict source_file
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [ldconfig]="$(koopa_linux_locate_ldconfig)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [distro_prefix]="$(koopa_distro_prefix)"
        [target_prefix]='/etc/ld.so.conf.d'
    )
    [[ -d "${dict[target_prefix]}" ]] || return 0
    dict[conf_source]="${dict[distro_prefix]}${dict[target_prefix]}"
    # Intentionally early return for distros that don't need configuration.
    [[ -d "${dict[conf_source]}" ]] || return 0
    # Create symlinks with 'koopa-' prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    koopa_alert "Updating ldconfig in '${dict[target_prefix]}'."
    for source_file in "${dict[conf_source]}/"*".conf"
    do
        local target_bn target_file
        target_bn="koopa-$(koopa_basename "$source_file")"
        target_file="${dict[target_prefix]}/${target_bn}"
        koopa_ln --sudo "$source_file" "$target_file"
    done
    "${app[sudo]}" "${app[ldconfig]}" || true
    return 0
}
