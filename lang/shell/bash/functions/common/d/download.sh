#!/usr/bin/env bash

koopa_download() {
    # """
    # Download a file.
    # @note Updated 2023-04-05.
    #
    # Some web servers may fail unless we appear to be a web browser.
    #
    # @section curl:
    #
    # Potentially useful arguments:
    # * --connect-timeout <seconds>
    # * --progress-bar
    # * --silent
    # * --stderr
    # * -q, --disable: Disable '.curlrc' file.
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # @section wget:
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    local -A app bool dict
    local -a download_args pos
    koopa_assert_has_args "$#"
    bool['decompress']=0
    bool['extract']=0
    bool['progress']=1
    dict['engine']='curl'
    dict['file']="${2:-}"
    dict['url']="${1:?}"
    dict['user_agent']="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; \
rv:109.0) Gecko/20100101 Firefox/111.0"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--decompress')
                bool['decompress']=1
                shift 1
                ;;
            '--extract')
                bool['extract']=1
                shift 1
                ;;
            '--progress')
                bool['progress']=1
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
    koopa_assert_has_args_le "$#" 2
    app['download']="$("koopa_locate_${dict['engine']}" --allow-system)"
    [[ -x "${app['download']}" ]] || exit 1
    if [[ -z "${dict['file']}" ]]
    then
        dict['file']="$(koopa_basename "${dict['url']}")"
        if koopa_str_detect_fixed --string="${dict['file']}" --pattern='%'
        then
            dict['file']="$( \
                koopa_print "${dict['file']}" \
                | koopa_gsub \
                    --fixed \
                    --pattern='%2D' \
                    --replacement='-' \
                | koopa_gsub \
                    --fixed \
                    --pattern='%2E' \
                    --replacement='.' \
                | koopa_gsub \
                    --fixed \
                    --pattern='%5F' \
                    --replacement='_' \
                | koopa_gsub \
                    --fixed \
                    --pattern='%20' \
                    --replacement='_' \
            )"
        fi
    fi
    if ! koopa_str_detect_fixed \
        --string="${dict['file']}" \
        --pattern='/'
    then
        dict['file']="${PWD:?}/${dict['file']}"
    fi
    download_args=()
    case "${dict['engine']}" in
        'curl')
            # Inclusion of '--progress' shows a simple progress bar.
            download_args+=(
                '--disable' # Ignore '~/.curlrc'. Must come first.
                '--create-dirs'
                '--fail'
                '--location'
                '--output' "${dict['file']}"
                '--retry' 5
                '--show-error'
            )
            case "${dict['url']}" in
                *'sourceforge.net/'*)
                    ;;
                *)
                    download_args+=(
                        '--user-agent' "${dict['user_agent']}"
                    )
                    ;;
            esac
            if [[ "${bool['progress']}" -eq 0 ]]
            then
                # Alternatively, can use '--no-progress-meter'.
                download_args+=('--silent')
            fi
            ;;
        'wget')
            download_args+=(
                "--output-document=${dict['file']}"
                '--no-verbose'
            )
            if [[ "${bool['progress']}" -eq 0 ]]
            then
                download_args+=('--quiet')
            fi
            ;;
    esac
    download_args+=("${dict['url']}")
    koopa_alert "Downloading '${dict['url']}' to '${dict['file']}'."
    "${app['download']}" "${download_args[@]}"
    if [[ "${bool['decompress']}" -eq 1 ]]
    then
        koopa_decompress "${dict['file']}"
    elif [[ "${bool['extract']}" -eq 1 ]]
    then
        koopa_extract "${dict['file']}"
    fi
    return 0
}
