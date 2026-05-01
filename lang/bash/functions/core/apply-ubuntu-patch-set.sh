#!/usr/bin/env bash

_koopa_apply_ubuntu_patch_set() {
    # """
    # Apply Ubuntu patch set.
    # @note Updated 2023-06-01.
    # """
    local -A app dict
    local -a patch_series
    app['patch']="$(_koopa_locate_patch)"
    _koopa_assert_is_executable "${app[@]}"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--patch-version' "${dict['patch_version']}" \
        '--target' "${dict['target']}" \
        '--version' "${dict['version']}"
    _koopa_assert_is_dir "${dict['target']}"
    dict['url']="http://archive.ubuntu.com/ubuntu/pool/main/\
${dict['name']:0:1}/${dict['name']}/${dict['name']}_${dict['version']}-\
${dict['patch_version']}ubuntu1.debian.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'debian'
    _koopa_assert_is_file 'debian/patches/series'
    readarray -t patch_series < 'debian/patches/series'
    (
        local patch
        _koopa_cd "${dict['target']}"
        for patch in "${patch_series[@]}"
        do
            local input
            input="$(_koopa_realpath .."/debian/patches/${patch}")"
            _koopa_alert "Applying patch from '${input}'."
            "${app['patch']}" \
                --input="$input" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}
