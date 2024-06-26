#!/usr/bin/env bash

koopa_link_in_dir() {
    # """
    # Symlink multiple programs in a directory.
    # @note Updated 2024-06-26.
    #
    # @usage
    # > koopa_link_in_dir \
    # >     --name=TARGET_NAME \
    # >     --prefix=TARGET_PREFIX \
    # >     --source=SOURCE_FILE \
    #
    # @examples
    # > koopa_link_in_dir \
    # >     --name='emacs' \
    # >     --prefix="$(koopa_bin_prefix)" \
    # >     --source='/usr/local/bin/emacs'
    # """
    local -A dict
    koopa_assert_has_args "$#"
    dict['name']=''
    dict['prefix']=''
    dict['source']=''
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
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--source='*)
                dict['source']="${1#*=}"
                shift 1
                ;;
            '--source')
                dict['source']="${2:?}"
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
        '--prefix' "${dict['prefix']}" \
        '--source' "${dict['source']}"
    [[ ! -d "${dict['prefix']}" ]] && koopa_mkdir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    dict['target']="${dict['prefix']}/${dict['name']}"
    koopa_assert_is_existing "${dict['source']}"
    koopa_ln "${dict['source']}" "${dict['target']}"
    return 0
}
