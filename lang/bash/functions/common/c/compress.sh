#!/usr/bin/env bash

koopa_compress() {
    # """
    # Compress multiple files.
    # @note Updated 2023-11-07.
    # """
    local -A app bool dict
    local -a cmd_args pos
    local source_file
    koopa_assert_has_args "$#"
    bool['keep']=0
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
            '-')
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
        local target_file
        source_file="$(koopa_realpath "$source_file")"
        target_file="${source_file}.${dict['ext']}"
        koopa_assert_is_not_file "$target_file"
        koopa_alert "Compressing '${source_file}' to '${target_file}'."
        "${app['cmd']}" "${cmd_args[@]}" "$source_file"
        koopa_assert_is_file "$target_file"
    done
    if [[ "${bool['keep']}" -eq 0 ]]
    then
        koopa_rm "$@"
    fi
    return 0
}
