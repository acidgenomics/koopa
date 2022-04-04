#!/usr/bin/env bash

# Note that these are defined primarily to catch errors in private scripts that
# are defined outside of the koopa package.

koopa_defunct() { # {{{1
    # """
    # Make a function defunct.
    # @note Updated 2020-02-18.
    # """
    local msg new
    new="${1:-}"
    msg='Defunct.'
    if [[ -n "$new" ]]
    then
        msg="${msg} Use '${new}' instead."
    fi
    koopa_stop "${msg}"
}

# Soft deprecations ============================================================
koopa_activate_conda_env() { # {{{1
    koopa_conda_activate_env "$@"
}

koopa_deactivate_conda() { # {{{1
    koopa_conda_deactivate "$@"
}

# Defunct functions ============================================================
koopa_brew_update() { # {{{1
    # """
    # @note Updated 2020-12-17.
    # """
    koopa_defunct 'koopa_update_homebrew'
}

koopa_check_data_disk() { # {{{1
    # """
    # @note Updated 2020-11-19.
    # """
    koopa_defunct
}

koopa_configure_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_configure_start'
}

koopa_configure_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_configure_success'
}

koopa_data_disk_link_prefix() { # {{{1
    # """
    # @note Updated 2021-12-09.
    # """
    koopa_defunct
}

koopa_file_match_fixed() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa_defunct 'koopa_file_detect_fixed'
}

koopa_file_match_regex() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa_defunct 'koopa_file_detect_regex'
}

koopa_info() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa_defunct 'koopa_alert_info'
}

koopa_install_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_install_start'
}

koopa_install_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_install_success'
}

koopa_is_darwin() { # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    koopa_defunct 'koopa_is_macos'
}

koopa_is_matching_fixed() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa_defunct 'koopa_str_detect_fixed'
}

koopa_is_matching_regex() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa_defunct 'koopa_str_detect_regex'
}

koopa_local_app_prefix() { # {{{1
    # """
    # @note Updated 2020-11-19.
    # """
    koopa_defunct 'koopa_local_data_prefix'
}

koopa_note() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa_defunct 'koopa_alert_note'
}

koopa_quiet_cd() { # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    koopa_defunct 'koopa_cd'
}

koopa_remove_broken_symlinks() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa_defunct 'koopa_delete_broken_symlinks'
}

koopa_remove_empty_dirs() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa_defunct 'koopa_delete_empty_dirs'
}

koopa_restart() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa_defunct 'koopa_alert_restart'
}

koopa_str_match_fixed() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa_defunct 'koopa_str_detect_fixed'
}

koopa_str_match_regex() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa_defunct 'koopa_str_detect_regex'
}

koopa_success() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa_defunct 'koopa_alert_success'
}

koopa_uninstall_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_uninstall_start'
}

koopa_uninstall_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_uninstall_success'
}

koopa_update_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_update_start'
}

koopa_update_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa_defunct 'koopa_alert_update_success'
}
