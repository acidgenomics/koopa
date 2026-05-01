#!/usr/bin/env bash

main() {
    # """
    # Apply bootstrap configuration to our Debian/Ubuntu builder instances.
    # @note Updated 2024-06-27.
    #
    # @section apt install:
    #
    # Needed for compiling software: 'gcc' 'g++' 'libc-dev' 'make'. Don't
    # include 'zlib1g-dev' here. We want to ensure that our build recipes are
    # hardened with a local copy of zlib.
    #
    # @section: needrestart:
    #
    # This still isn't fixing system R install inside an isolated shell on
    # Ubuntu 22. Not sure how to resolve this currently.
    #
    # @seealso
    # - https://www.serverlab.ca/tutorials/linux/administration-linux/
    #     how-to-check-and-set-timezone-in-ubuntu-20-04/
    # - https://sleeplessbeastie.eu/2018/09/17/
    #     how-to-read-and-insert-new-values-into-the-debconf-database/
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_alert 'Configuring system defaults.'
    _koopa_add_to_path_end '/usr/sbin' '/sbin'
    _koopa_print_env
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['debconf_set_selections']="$( \
        _koopa_debian_locate_debconf_set_selections \
    )"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_debian_apt_configure_sources
    _koopa_debian_apt_get update
    _koopa_debian_apt_get full-upgrade
    if _koopa_linux_is_init_systemd
    then
        "${app['cat']}" << END | _koopa_sudo "${app['debconf_set_selections']}"
tzdata tzdata/Areas select America
tzdata tzdata/Zones/America select New_York
END
    fi
    _koopa_debian_apt_install \
        'bash' \
        'ca-certificates' \
        'coreutils' \
        'curl' \
        'findutils' \
        'g++' \
        'gcc' \
        'gfortran' \
        'git' \
        'libc-dev' \
        'libgmp-dev' \
        'libudev-dev' \
        'locales' \
        'lsb-release' \
        'make' \
        'perl' \
        'procps' \
        'sudo' \
        'systemd' \
        'tzdata' \
        'unzip' \
        'zsh'
    app['dpkg_reconfigure']="$(_koopa_debian_locate_dpkg_reconfigure)"
    app['locale_gen']="$(_koopa_debian_locate_locale_gen)"
    app['update_locale']="$(_koopa_debian_locate_update_locale)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_debian_apt_get autoremove
    _koopa_debian_apt_get clean
    _koopa_debian_set_timezone
    _koopa_sudo_write_string \
        --file='/etc/locale.gen' \
        --string='en_US.UTF-8 UTF-8'
    _koopa_sudo "${app['locale_gen']}" --purge
    _koopa_sudo "${app['dpkg_reconfigure']}" \
        --frontend='noninteractive' locales
    _koopa_sudo "${app['update_locale']}" LANG='en_US.UTF-8'
    # > _koopa_debian_needrestart_noninteractive
    # > _koopa_enable_passwordless_sudo
    _koopa_linux_configure_system_sshd
    _koopa_alert_success 'Configuration of system defaults was successful.'
    return 0
}
