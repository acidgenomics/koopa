#!/usr/bin/env bash

koopa_macos_disable_touch_id_sudo() {
    # """
    # Disable sudo authentication via Touch ID PAM.
    # @note Updated 2021-10-30.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [cp]="$(koopa_locate_cp)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [source_file]="$(koopa_koopa_prefix)/os/macos/etc/pam.d/sudo~orig"
        [target_file]='/etc/pam.d/sudo'
    )
    if [[ -f "${dict[target_file]}" ]] && \
        ! koopa_file_detect_fixed \
            --file="${dict[target_file]}" \
            --pattern='pam_tid.so'
    then
        koopa_alert_note "Touch ID not enabled in '${dict[target_file]}'."
        return 0
    fi
    koopa_alert "Disabling Touch ID defined in '${dict[target_file]}'."
    # NOTE Don't use 'koopa_cp' here, as it will remove the target file
    # and can cause system lockout in this case.
    "${app[sudo]}" "${app[cp]}" -v \
        "${dict[source_file]}" "${dict[target_file]}"
    koopa_chmod --sudo '0444' "${dict[target_file]}"
    koopa_alert_success 'Touch ID disabled for sudo.'
    return 0
}
