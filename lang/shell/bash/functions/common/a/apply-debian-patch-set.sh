#!/usr/bin/env bash

koopa_apply_debian_patch_set() {
    # """
    # Apply Debian patch set.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    local -a patch_series
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']=''
    dict['patch_version']=''
    dict['target']=''
    dict['version']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--patch-version='*)
                dict['patch_version']="${1#*=}"
                shift 1
                ;;
            '--patch-version')
                dict['patch_version']="${2:?}"
                shift 2
                ;;
            '--target='*)
                dict['target']="${1#*=}"
                shift 1
                ;;
            '--target')
                dict['target']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--patch-version' "${dict['patch_version']}" \
        '--target' "${dict['target']}" \
        '--version' "${dict['version']}"
    koopa_assert_is_dir "${dict['target']}"
    dict['url']="https://deb.debian.org/debian/pool/main/${dict['name']:0:1}/\
${dict['name']}/${dict['name']}_${dict['version']}-${dict['patch_version']}.\
debian.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")"
    koopa_assert_is_dir 'debian/patches'
    koopa_assert_is_file 'debian/patches/series'
    readarray -t patch_series < 'debian/patches/series'
    (
        local patch
        koopa_cd "${dict['target']}"
        for patch in "${patch_series[@]}"
        do
            local input
            input="$(koopa_realpath "../debian/patches/${patch}")"
            koopa_alert "Applying patch from '${input}'."
            "${app['patch']}" \
                --input="$input" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}
