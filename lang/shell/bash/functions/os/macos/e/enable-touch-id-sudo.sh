#!/usr/bin/env bash

koopa_macos_enable_touch_id_sudo() {
    # """
    # Enable sudo authentication via Touch ID PAM.
    # @note Updated 2021-10-30.
    #
    # @seealso
    # - https://davidwalsh.name/touch-sudo
    # - https://news.ycombinator.com/item?id=26302139
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [cp]="$(koopa_locate_cp)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[cp]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    declare -A dict=(
        [source_file]="$(koopa_koopa_prefix)/os/macos/etc/pam.d/sudo"
        [target_file]='/etc/pam.d/sudo'
    )
    if [[ -f "${dict[target_file]}" ]] && \
        koopa_file_detect_fixed \
            --file="${dict[target_file]}" \
            --pattern='pam_tid.so'
    then
        koopa_alert_note "Touch ID already enabled in '${dict[target_file]}'."
        return 0
    fi
    koopa_alert "Enabling Touch ID in '${dict[target_file]}'."
    koopa_assert_is_file "${dict[source_file]}"
    # NOTE Don't use 'koopa_cp' here, as it will remove the target file
    # and can cause system lockout in this case.
    "${app[sudo]}" "${app[cp]}" -v \
        "${dict[source_file]}" "${dict[target_file]}"
    koopa_chmod --sudo '0444' "${dict[target_file]}"
    koopa_alert_success 'Touch ID enabled for sudo.'
    return 0
}
