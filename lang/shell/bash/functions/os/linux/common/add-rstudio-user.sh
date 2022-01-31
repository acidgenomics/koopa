#!/usr/bin/env bash

# FIXME This is currently prompting for password interactively.
# We don't want this.

koopa::linux_add_rstudio_user() { #{{{1
    # """
    # Enable RStudio user on Linux.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [passwd]="$(koopa::locate_passwd)"
        [sudo]="$(koopa::locate_sudo)"
        [useradd]="$(koopa::linux_locate_useradd)"
        [usermod]="$(koopa::linux_locate_usermod)"
    )
    declare -A dict=(
        [home]='/home/rstudio'
        [shell]='/bin/bash'
        [user]='rstudio'
    )
    "${app[sudo]}" "${app[useradd]}" "${dict[user]}"
    "${app[sudo]}" "${app[passwd]}" "${dict[user]}"
    koopa::mkdir --sudo "${dict[home]}"
    koopa::chown --sudo "${dict[user]}:${dict[user]}" "${dict[home]}"
    "${app[sudo]}" "${app[usermod]}" -s "${dict[shell]}" "${dict[user]}"
    return 0
}
