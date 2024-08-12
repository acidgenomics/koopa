#!/usr/bin/env bash

# FIXME Consider reworking with patch approach instead.

koopa_macos_enable_touch_id_sudo() {
    # """
    # Enable sudo authentication via Touch ID PAM.
    # @note Updated 2022-10-06.
    #
    # @seealso
    # - https://davidwalsh.name/touch-sudo
    # - https://news.ycombinator.com/item?id=26302139
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    local -A dict
    dict['file']='/etc/pam.d/sudo'
    if [[ -f "${dict['file']}" ]] && \
        koopa_file_detect_fixed \
            --file="${dict['file']}" \
            --pattern='pam_tid.so'
    then
        koopa_alert_note "Touch ID already enabled in '${dict['file']}'."
        return 0
    fi
    koopa_alert "Enabling Touch ID in '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
# sudo: auth account password session
auth       sufficient     pam_tid.so
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
END
    koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    koopa_chmod --sudo '0444' "${dict['file']}"
    koopa_alert_success 'Touch ID enabled for sudo.'
    return 0
}
