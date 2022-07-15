#!/usr/bin/env bash

koopa_linux_update_system_sshd_config() {
    # """
    # Update sshd configuration.
    # @note Updated 2022-07-15.
    #
    # Creates a 'koopa.conf' file, which contains passthrough support of
    # 'KOOPA_COLOR_MODE' environment variable.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [source_file]="$(koopa_koopa_prefix)/os/linux/common/etc/ssh/\
sshd_config.d/koopa.conf"
        [target_file]='/etc/ssh/sshd_config.d/koopa.conf'
    )
    koopa_ln --sudo "${dict[source_file]}" "${dict[target_file]}"
    return 0
}
