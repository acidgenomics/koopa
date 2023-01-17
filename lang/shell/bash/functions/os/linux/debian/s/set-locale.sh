#!/usr/bin/env bash

koopa_debian_set_locale() {
    # """
    # Set locale to English US UTF-8.
    # @note Updated 2022-03-09.
    #
    # Refer to '/usr/share/i18n/SUPPORTED' for supported locales.
    #
    # NOTE Don't set 'LC_ALL' here, it overrides everything, and is explicitly
    # discouraged in the official Debian documentation.
    #
    # @seealso
    # - https://wiki.debian.org/Locale
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        ['dpkg_reconfigure']="$(koopa_debian_locate_dpkg_reconfigure)"
        ['locale']="$(koopa_locate_locale)"
        ['locale_gen']="$(koopa_debian_locate_locale_gen)"
        ['sudo']="$(koopa_locate_sudo)"
        ['update_locale']="$(koopa_debian_locate_update_locale)" 
    )
    [[ -x "${app['dpkg_reconfigure']}" ]] || return 1
    [[ -x "${app['locale']}" ]] || return 1
    [[ -x "${app['locale_gen']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['update_locale']}" ]] || return 1
    declare -A dict=(
        ['charset']='UTF-8'
        ['country']='US'
        ['lang']='en'
        ['locale_file']='/etc/locale.gen'
    )
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