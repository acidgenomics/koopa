#!/usr/bin/env bash

# FIXME Consider reworking with patch approach instead.

koopa_macos_disable_touch_id_sudo() {
    # """
    # Disable sudo authentication via Touch ID PAM.
    # @note Updated 2021-10-30.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    dict['file']='/etc/pam.d/sudo'
    if [[ -f "${dict['file']}" ]] && \
        ! koopa_file_detect_fixed \
            --file="${dict['file']}" \
            --pattern='pam_tid.so'
    then
        koopa_alert_note "Touch ID not enabled in '${dict['file']}'."
        return 0
    fi
    koopa_alert "Disabling Touch ID defined in '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
# sudo: auth account password session
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
END
    koopa_chmod --sudo '0444' "${dict['file']}"
    koopa_alert_success 'Touch ID disabled for sudo.'
    return 0
}
