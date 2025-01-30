#!/usr/bin/env bash

main() {
    # """
    # Configure system sshd.
    # @note Updated 2025-01-30.
    #
    # Creates a 'koopa.conf' file, which contains passthrough support of
    # 'KOOPA_COLOR_MODE' environment variable.
    #
    # This configuration enables passthrough of 'dark' / 'light' color mode from
    # local machine.
    #
    # @section Restart sshd service:
    #
    # Debian / Ubuntu:
    # > sudo systemctl restart ssh.service
    #
    # Fedora / RHEL / CentOS:
    # > sudo systemctl restart sshd.service
    #
    # @seealso
    # - https://koopa.acidgenomics.com/
    # - /etc/ssh/sshd_config
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['koopa_file']='/etc/ssh/sshd_config.d/koopa.conf'
    dict['sshd_file']='/etc/ssh/sshd_config'
    koopa_assert_is_file "${dict['sshd_file']}"
    if ! koopa_file_detect_regex \
        --file="${dict['sshd_file']}" \
        --pattern='^Include /etc/ssh/sshd_config.d/*.conf$'
    then
        koopa_alert_note "Modifying '${dict['sshd_file']}' to include \
'sshd_config.d'."
        read -r -d '' "dict[sshd_string]" << END || true
Include /etc/ssh/sshd_config.d/*.conf
END
        koopa_sudo_append_string \
            --file="${dict['sshd_file']}" \
            --string="${dict['sshd_string']}"
    fi
    koopa_chmod --sudo 0644 "${dict['sshd_file']}"
    koopa_alert "Modifying '${dict['koopa_file']}'."
    read -r -d '' "dict[koopa_string]" << END || true
AcceptEnv KOOPA_COLOR_MODE
END
    koopa_sudo_write_string \
        --file="${dict['koopa_file']}" \
        --string="${dict['koopa_string']}"
    koopa_chmod --sudo 0644 "${dict['koopa_file']}"
    return 0
}
