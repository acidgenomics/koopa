#!/usr/bin/env bash

# FIXME Improve support for parallel lzip, xz, zstd.
# --with-gzip=pigz --with-bzip2=lbzip2 --with-lzip=plzip
# > tar -I "xz -T0" -cf my_archive.tar.xz ./stuff_to_compress
# > tar -I "zstd -T0" -cf my_archive.tar.zst ./stuff_to_compress

koopa_compress() {
    # """
    # Compress multiple files.
    # @note Updated 2023-11-10.
    #
    # @section xz multithreading support:
    #
    # If you are running version 5.2.0 or above of XZ Utils, you can utilize
    # multiple cores for compression by setting '-T' or '--threads' to an
    # appropriate value via the environmental variable XZ_DEFAULTS
    # (e.g. XZ_DEFAULTS="-T 0").
    #
    # @seealso
    # - https://stackoverflow.com/questions/12313242/
    # - https://stackoverflow.com/a/27541309/3911732/
    # - https://www.reddit.com/r/linux/comments/rf1zty/
    # """
    local -A app bool dict
    local -a cmd_args pos
    local source_file
    koopa_assert_has_args "$#"
    bool['keep']=1
    bool['verbose']=0
    dict['format']='gzip'
    dict['threads']="$(koopa_cpu_count)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--format='*)
                dict['format']="${1#*=}"
                shift 1
                ;;
            '--format')
                dict['format']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--keep')
                bool['keep']=1
                shift 1
                ;;
            '--no-keep' | '--remove')
                bool['keep']=0
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--format' "${dict['format']}"
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    koopa_assert_is_not_compressed_file "$@"
    case "${dict['format']}" in
        'br' | 'brotli')
            app['cmd']="$(koopa_locate_brotli --allow-system)"
            dict['ext']='br'
            ;;
        'bz2' | 'bzip2')
            app['cmd']="$( \
                koopa_locate_pbzip2 --allow-missing --allow-system \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                dict['processes']="$(koopa_cpu_count)"
                cmd_args+=("-p${dict['processes']}")
            else
                app['cmd']="$(koopa_locate_bzip2 --allow-system)"
            fi
            dict['ext']='bz2'
            ;;
        'gz' | 'gzip')
            app['cmd']="$( \
                koopa_locate_pigz --allow-system --allow-missing \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                dict['processes']="$(koopa_cpu_count)"
                cmd_args+=('-p' "${dict['processes']}")
            else
                app['cmd']="$( \
                    koopa_locate_gzip --allow-system --allow-missing \
                )"
            fi
            dict['ext']='gz'
            ;;
        'lz' | 'lzip')
            app['cmd']="$(koopa_locate_lzip --allow-system)"
            dict['ext']='lz'
            ;;
        'lz4')
            app['cmd']="$(koopa_locate_lz4 --allow-system)"
            dict['ext']='lz4'
            [[ "${bool['verbose']}" -eq 0 ]] && cmd_args+=('-q')
            ;;
        'lzma')
            app['cmd']="$(koopa_locate_lzma --allow-system)"
            dict['ext']='lzma'
            ;;
        'xz')
            app['cmd']="$(koopa_locate_xz --allow-system)"
            dict['ext']='xz'
            ;;
        'zst' | 'zstd')
            app['cmd']="$(koopa_locate_zstd --allow-system)"
            dict['ext']='zst'
            [[ "${bool['verbose']}" -eq 0 ]] && cmd_args+=('-q')
            ;;
        *)
            koopa_stop "Unsupported format: '${dict['format']}'."
            ;;
    esac
    koopa_assert_is_executable "${app['cmd']}"
    cmd_args+=('-k')
    [[ "${bool['verbose']}" -eq 1 ]] && cmd_args+=('-v')
    for source_file in "$@"
    do
        local -A dict2
        dict2['source_file']="$source_file"
        dict2['source_file']="$(koopa_realpath "${dict2['source_file']}")"
        dict2['target_file']="${dict2['source_file']}.${dict['ext']}"
        koopa_assert_is_not_file "${dict2['target_file']}"
        koopa_alert "Compressing '${dict2['source_file']}' \
to '${dict2['target_file']}'."
        "${app['cmd']}" "${cmd_args[@]}" "${dict2['source_file']}"
        koopa_assert_is_file \
            "${dict2['source_file']}" \
            "${dict2['target_file']}"
        if [[ "${bool['keep']}" -eq 0 ]]
        then
            koopa_rm "${dict2['target_file']}"
        fi
    done
    return 0
}
