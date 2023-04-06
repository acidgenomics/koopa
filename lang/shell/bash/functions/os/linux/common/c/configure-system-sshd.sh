#!/usr/bin/env bash

koopa_linux_configure_system_sshd() {
    # """
    # Configure system sshd.
    # @note Updated 2023-03-21.
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
    koopa_assert_is_admin
    dict['file']='/etc/ssh/sshd_config.d/koopa.conf'
    read -r -d '' "dict[string]" << END || true
AcceptEnv KOOPA_COLOR_MODE
END
    koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    return 0
}
