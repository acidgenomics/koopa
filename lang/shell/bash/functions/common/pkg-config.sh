#!/usr/bin/env bash

koopa_activate_opt_prefix() { # {{{1
    # """
    # Activate koopa opt prefix.
    # @note Updated 2022-04-11.
    #
    # @examples
    # > koopa_activate_opt_prefix 'geos' 'proj' 'gdal'
    # """
    local dict name
    koopa_assert_has_args "$#"
    declare -A dict=(
        [cppflags]="${CPPFLAGS:-}"
        [ldflags]="${LDFLAGS:-}"
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    for name in "$@"
    do
        local dict2 str
        declare -A dict2
        dict2[prefix]="${dict[opt_prefix]}/${name}"
        koopa_assert_is_dir "${dict2[prefix]}"
        if koopa_is_empty_dir "${dict2[prefix]}"
        then
            koopa_stop "'${dict2[prefix]}' is empty."
        fi
        koopa_alert "Activating '${dict2[prefix]}'."
        dict2[include]="${dict2[prefix]}/include"
        dict2[lib64]="${dict2[prefix]}/lib64"
        dict2[lib]="${dict2[prefix]}/lib"
        # PATH.
        koopa_activate_prefix "${dict2[prefix]}"
        # PKG_CONFIG_PATH.
        koopa_add_to_pkg_config_path_start \
            "${dict2[prefix]}/lib/pkgconfig" \
            "${dict2[prefix]}/lib64/pkgconfig" \
            "${dict2[prefix]}/share/pkgconfig"
        # CPPFLAGS.
        if [[ -d "${dict2[include]}" ]]
        then
            str="-I${dict2[include]}"
            if [[ -n "${dict[cppflags]}" ]]
            then
                dict[cppflags]="${dict[cppflags]} ${str}"
            else
                dict[cppflags]="$str"
            fi
        fi
        # LDFLAGS.
        if [[ -d "${dict2[lib]}" ]]
        then
            str="-L${dict2[lib]} -Wl,-rpath,${dict2[lib]}"
            if [[ -n "${dict[ldflags]}" ]]
            then
                dict[ldflags]="${dict[ldflags]} ${str}"
            else
                dict[ldflags]="$str"
            fi
        fi
        if [[ -d "${dict2[lib64]}" ]]
        then
            str="-L${dict2[lib64]} -Wl,-rpath,${dict2[lib64]}"
            if [[ -n "${dict[ldflags]}" ]]
            then
                dict[ldflags]="${dict[ldflags]} ${str}"
            else
                dict[ldflags]="$str"
            fi
        fi
    done
    if [[ -n "${dict[cppflags]}" ]]
    then
        CPPFLAGS="${dict[cppflags]}"
        export CPPFLAGS
    fi
    if [[ -n "${dict[ldflags]}" ]]
    then
        LDFLAGS="${dict[ldflags]}"
        export LDFLAGS
    fi
    return 0
}
