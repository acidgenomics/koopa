#!/usr/bin/env bash

koopa_debian_set_locale() {
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2023-04-05.
    #
    # Refer to '/usr/share/i18n/SUPPORTED' for supported locales.
    #
    # NOTE Don't set 'LC_ALL' here, it overrides everything, and is explicitly
    # discouraged in the official Debian documentation.
    #
    # @seealso
    # - https://wiki.debian.org/Locale
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['dpkg_reconfigure']="$(koopa_debian_locate_dpkg_reconfigure)"
    app['locale']="$(koopa_locate_locale)"
    app['locale_gen']="$(koopa_debian_locate_locale_gen)"
    app['sudo']="$(koopa_locate_sudo)"
    app['update_locale']="$(koopa_debian_locate_update_locale)"
    koopa_assert_is_executable "${app[@]}"
    dict['charset']='UTF-8'
    dict['country']='US'
    dict['lang']='en'
    dict['locale_file']='/etc/locale.gen'
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    koopa_alert "Setting locale to '${dict['lang_string']}'."
    koopa_sudo_write_string \
        --file="${dict['locale_file']}" \
        --string="${dict['lang_string']} ${dict['charset']}"
    "${app['sudo']}" "${app['locale_gen']}" --purge
    "${app['sudo']}" "${app['dpkg_reconfigure']}" \
        --frontend='noninteractive' \
        'locales'
    "${app['sudo']}" "${app['update_locale']}" LANG="${dict['lang_string']}"
    "${app['locale']}" -a
    return 0
}
