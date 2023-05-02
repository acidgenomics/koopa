#!/usr/bin/env bash

koopa_debian_install_system_builder_base() {
    # """
    # Bootstrap the Debian/Ubuntu builder AMI.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://www.serverlab.ca/tutorials/linux/administration-linux/
    #     how-to-check-and-set-timezone-in-ubuntu-20-04/
    # - https://sleeplessbeastie.eu/2018/09/17/
    #     how-to-read-and-insert-new-values-into-the-debconf-database/
    # """
    local -A app
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['debconf_set_selections']="$( \
        koopa_debian_locate_debconf_set_selections \
    )"
    app['echo']="$(koopa_locate_echo --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['apt_get']}" update
    koopa_sudo \
        DEBCONF_NONINTERACTIVE_SEEN='true' \
        DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" full-upgrade --yes
    "${app['cat']}" << END \
        | koopa_sudo "${app['debconf_set_selections']}"
tzdata tzdata/Areas select America
tzdata tzdata/Zones/America select New_York
END
    # Needed for compiling software: 'gcc' 'g++' 'libc-dev' 'make'. Don't
    # include 'zlib1g-dev' here. We want to ensure that our build recipes are
    # hardened with a local copy of zlib.
    koopa_sudo \
        DEBCONF_NONINTERACTIVE_SEEN='true' \
        DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" \
        --no-install-recommends \
        --yes \
        install \
            'bash' \
            'ca-certificates' \
            'coreutils' \
            'curl' \
            'findutils' \
            'g++' \
            'gcc' \
            'git' \
            'libc-dev' \
            'libgmp-dev' \
            'locales' \
            'lsb-release' \
            'make' \
            'perl' \
            'procps' \
            'sudo' \
            'systemd' \
            'tzdata' \
            'unzip'
    app['dpkg_reconfigure']="$(koopa_debian_locate_dpkg_reconfigure)"
    app['locale_gen']="$(koopa_debian_locate_locale_gen)"
    app['timedatectl']="$(koopa_debian_locate_timedatectl)"
    app['update_locale']="$(koopa_debian_locate_update_locale)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['apt_get']}" autoremove --yes
    koopa_sudo "${app['apt_get']}" clean
    koopa_sudo "${app['timedatectl']}" set-timezone 'America/New_York'
    koopa_sudo_write_string \
        --file='/etc/locale.gen' \
        --string='en_US.UTF-8 UTF-8'
    koopa_sudo "${app['locale_gen']}" --purge
    koopa_sudo "${app['dpkg_reconfigure']}" \
        --frontend='noninteractive' locales
    koopa_sudo "${app['update_locale']}" LANG='en_US.UTF-8'
    koopa_enable_passwordless_sudo
    return 0
}
