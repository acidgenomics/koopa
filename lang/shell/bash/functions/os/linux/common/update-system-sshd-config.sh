#!/usr/bin/env bash

koopa_linux_update_system_sshd_config() {
    # """
    # Update sshd configuration.
    # @note Updated 2022-10-06.
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
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict
    dict['file']='/etc/ssh/sshd_config.d/koopa.conf'
    read -r -d '' "dict[string]" << END || true
AcceptEnv KOOPA_COLOR_MODE
END
    koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    return 0
}
