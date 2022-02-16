#!/usr/bin/env bash

# Note that these are defined primarily to catch errors in private scripts that
# are defined outside of the koopa package.

koopa::defunct() { # {{{1
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
    koopa::stop "${msg}"
}

# Soft deprecations ============================================================
koopa::active_conda_env() { # {{{1
    koopa::conda_activate_env "$@"
}

# Defunct functions ============================================================
koopa::brew_update() { # {{{1
    # """
    # @note Updated 2020-12-17.
    # """
    koopa::defunct 'koopa::update_homebrew'
}

koopa::cellar_prefix() { # {{{1
    # """
    # @note Updated 2020-11-19.
    # """
    koopa::defunct 'koopa::app_prefix'
}

koopa::check_data_disk() { # {{{1
    # """
    # @note Updated 2020-11-19.
    # """
    koopa::defunct
}

koopa::configure_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_configure_start'
}

koopa::configure_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_configure_success'
}

koopa::data_disk_link_prefix() { # {{{1
    # """
    # @note Updated 2021-12-09.
    # """
    koopa::defunct
}

koopa::file_match_fixed() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa::defunct 'koopa::file_detect_fixed'
}

koopa::file_match_regex() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa::defunct 'koopa::file_detect_regex'
}

koopa::find_cellar_version() { # {{{1
    # """
    # @note Updated 2020-11-22.
    # """
    koopa::defunct 'koopa::find_app_version'
}

koopa::find_non_cellar_make_files() { # {{{1
    # """
    # @note Updated 2020-11-23.
    # """
    koopa::defunct 'koopa::find_non_symlinked_make_files'
}

koopa::info() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa::defunct 'koopa::alert_info'
}

koopa::install_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_install_start'
}

koopa::install_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_install_success'
}

koopa::is_darwin() { # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    koopa::defunct 'koopa::is_macos'
}

koopa::is_matching_fixed() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa::defunct 'koopa::str_detect_fixed'
}

koopa::is_matching_regex() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa::defunct 'koopa::str_detect_regex'
}

koopa::link_cellar() { # {{{1
    # """
    # @note Updated 2020-11-23.
    # """
    koopa::defunct 'koopa::link_app'
}

koopa::linux_delete_broken_cellar_symlinks() { # {{{1
    # """
    # @note Updated 2020-11-23.
    # """
    koopa::defunct 'koopa::linux_delete_broken_app_symlinks'
}

koopa::linux_find_cellar_symlinks() { # {{{1
    # """
    # @note Updated 2020-11-23.
    # """
    koopa::defunct 'koopa::linux_find_app_symlinks'
}

koopa::list_cellar_versions() { # {{{1
    # """
    # @note Updated 2020-11-23.
    # """
    koopa::defunct 'koopa::list_app_versions'
}

koopa::local_app_prefix() { # {{{1
    # """
    # @note Updated 2020-11-19.
    # """
    koopa::defunct 'koopa::local_data_prefix'
}

koopa::note() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa::defunct 'koopa::alert_note'
}

koopa::prune_cellar() { # {{{1
    # """
    # @note Updated 2020-11-22.
    # """
    koopa::defunct 'koopa::prune_apps'
}

koopa::quiet_cd() { # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    koopa::defunct 'koopa::cd'
}

koopa::remove_broken_cellar_symlinks() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa::defunct 'koopa::delete_broken_app_symlinks'
}

koopa::remove_broken_symlinks() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa::defunct 'koopa::delete_broken_symlinks'
}

koopa::remove_empty_dirs() { # {{{1
    # """
    # @note Updated 2020-11-18.
    # """
    koopa::defunct 'koopa::delete_empty_dirs'
}

koopa::restart() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa::defunct 'koopa::alert_restart'
}

koopa::str_match_fixed() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa::defunct 'koopa::str_detect_fixed'
}

koopa::str_match_regex() {  #{{{1
    # """
    # @note Updated 2022-01-10.
    # """
    koopa::defunct 'koopa::str_detect_regex'
}

koopa::success() { # {{{1
    # """
    # @note Updated 2021-03-31.
    # """
    koopa::defunct 'koopa::alert_success'
}

koopa::uninstall_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_uninstall_start'
}

koopa::uninstall_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_uninstall_success'
}

koopa::unlink_cellar() { # {{{1
    # """
    # @note Updated 2020-11-11.
    # """
    koopa::defunct 'koopa::unlink_app'
}

koopa::update_start() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_update_start'
}

koopa::update_success() { # {{{1
    # """
    # @note Updated 2021-11-18.
    # """
    koopa::defunct 'koopa::alert_update_success'
}
