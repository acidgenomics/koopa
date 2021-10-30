#!/usr/bin/env bash

koopa::macos_disable_touch_id_sudo() { # {{{1
    # """
    # Disable sudo authentication via Touch ID PAM.
    # @note Updated 2021-10-30.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [cp]="$(koopa::locate_cp)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [source_file]="$(koopa::koopa_prefix)/os/macos/etc/pam.d/sudo~orig"
        [target_file]='/etc/pam.d/sudo'
    )
    if [[ -f "${dict[target_file]}" ]] && \
        ! koopa::file_match_fixed "${dict[target_file]}" 'pam_tid.so'
    then
        koopa::alert_note "Touch ID not enabled in '${dict[target_file]}'."
        return 0
    fi
    koopa::alert "Disabling Touch ID defined in '${dict[target_file]}'."
    # NOTE Don't use 'koopa::cp' here, as it will remove the target file
    # and can cause system lockout in this case.
    "${app[sudo]}" "${app[cp]}" -v "${dict[source_file]}" "${dict[target_file]}"
    koopa::chmod --sudo '0444' "${dict[target_file]}"
    koopa::alert_success 'Touch ID disabled for sudo.'
    return 0
}

koopa::macos_enable_touch_id_sudo() { # {{{1
    # """
    # Enable sudo authentication via Touch ID PAM.
    # @note Updated 2021-10-30.
    # @seealso
    # - https://davidwalsh.name/touch-sudo
    # - https://news.ycombinator.com/item?id=26302139
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [cp]="$(koopa::locate_cp)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [source_file]="$(koopa::koopa_prefix)/os/macos/etc/pam.d/sudo"
        [target_file]='/etc/pam.d/sudo'
    )
    if [[ -f "${dict[target_file]}" ]] && \
        koopa::file_match_fixed "${dict[target_file]}" 'pam_tid.so'
    then
        koopa::alert_note "Touch ID already enabled in '${dict[target_file]}'."
        return 0
    fi
    koopa::alert "Enabling Touch ID in '${dict[target_file]}'."
    koopa::assert_is_file "${dict[source_file]}"
    # NOTE Don't use 'koopa::cp' here, as it will remove the target file
    # and can cause system lockout in this case.
    "${app[sudo]}" "${app[cp]}" -v "${dict[source_file]}" "${dict[target_file]}"
    koopa::chmod --sudo '0444' "${dict[target_file]}"
    koopa::alert_success 'Touch ID enabled for sudo.'
    return 0
}
