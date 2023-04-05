#!/usr/bin/env bash

koopa_debian_install_system_builder_base() {
    # """
    # Bootstrap the Debian/Ubuntu builder AMI.
    # @note Updated 2023-03-02.
    #
    # @seealso
    # - https://www.serverlab.ca/tutorials/linux/administration-linux/
    #     how-to-check-and-set-timezone-in-ubuntu-20-04/
    # - https://sleeplessbeastie.eu/2018/09/17/
    #     how-to-read-and-insert-new-values-into-the-debconf-database/
    # """
    local app
    declare -A app=(
        ['apt_get']="$(koopa_debian_locate_apt_get)"
        ['cat']="$(koopa_locate_cat --allow-system)"
        ['debconf_set_selections']="$( \
            koopa_debian_locate_debconf_set_selections \
        )"
        ['echo']="$(koopa_locate_echo --allow-system)"
        ['sudo']="$(koopa_locate_sudo --allow-system)"
    )
    [[ -x "${app['apt_get']}" ]] || exit 1
    [[ -x "${app['cat']}" ]] || exit 1
    [[ -x "${app['debconf_set_selections']}" ]] || exit 1
    [[ -x "${app['echo']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    "${app['sudo']}" "${app['apt_get']}" update
    "${app['sudo']}" \
        DEBCONF_NONINTERACTIVE_SEEN='true' \
        DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" upgrade --yes
    # Using 'dist-upgrade' can be too aggressive.
    # > "${app['sudo']}" \
    # >     DEBCONF_NONINTERACTIVE_SEEN='true' \
    # >     DEBIAN_FRONTEND='noninteractive' \
    # >     "${app['apt_get']}" dist-upgrade --yes
    "${app['cat']}" << END \
        | "${app['sudo']}" "${app['debconf_set_selections']}"
tzdata tzdata/Areas select America
tzdata tzdata/Zones/America select New_York
END
    # Needed for compiling software: 'gcc' 'g++' 'libc-dev' 'make'. Don't
    # include 'zlib1g-dev' here. We want to ensure that our build recipes are
    # hardened with a local copy of zlib.
    "${app['sudo']}" \
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
    [[ -x "${app['dpkg_reconfigure']}" ]] || exit 1
    [[ -x "${app['locale_gen']}" ]] || exit 1
    [[ -x "${app['timedatectl']}" ]] || exit 1
    [[ -x "${app['update_locale']}" ]] || exit 1
    "${app['sudo']}" "${app['apt_get']}" autoremove --yes
    "${app['sudo']}" "${app['apt_get']}" clean
    "${app['sudo']}" "${app['timedatectl']}" set-timezone 'America/New_York'
    koopa_sudo_write_string \
        --file='/etc/locale.gen' \
        --string='en_US.UTF-8 UTF-8'
    "${app['sudo']}" "${app['locale_gen']}" --purge
    "${app['sudo']}" "${app['dpkg_reconfigure']}" \
        --frontend='noninteractive' locales
    "${app['sudo']}" "${app['update_locale']}" LANG='en_US.UTF-8'
    koopa_enable_passwordless_sudo
    return 0
}
