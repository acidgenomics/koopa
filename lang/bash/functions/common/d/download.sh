#!/usr/bin/env bash

# FIXME Currently can't get file name for figshare URLs:
# https://figshare.com/ndownloader/articles/24667905/versions/1

# FIXME Use these when we don't detect a filename:
# --remote-name
# --remote-header-name
# --output-dir='FIXME'

koopa_download() {
    # """
    # Download a file.
    # @note Updated 2023-12-12.
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
    # Alternatively, can detect remote file name with:
    # * --remote-header-name
    # * --remote-name
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # @section wget:
    #
    # Can detect remote file name with '--content-disposition' (experimental).
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    local -A app bool dict
    local -a curl_args pos
    koopa_assert_has_args "$#"
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['decompress']=0
    bool['extract']=0
    bool['progress']=1
    bool['remote_name']=0
    dict['user_agent']="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; \
rv:120.0) Gecko/20100101 Firefox/120.0"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--decompress')
                bool['decompress']=1
                shift 1
                ;;
            '--extract')
                bool['extract']=1
                shift 1
                ;;
            '--no-progress')
                bool['progress']=0
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
    dict['url']="${1:?}"
    dict['output']="${2:-}"
    # Inclusion of '--progress' shows a simple progress bar.
    curl_args+=(
        '--disable' # Ignore '~/.curlrc'. Must come first.
        '--create-dirs'
        '--fail'
        '--location'
        '--retry' 5
        '--show-error'
    )
    if [[ "${bool['progress']}" -eq 0 ]]
    then
        # Alternatively, can use '--no-progress-meter'.
        curl_args+=('--silent')
    fi
    case "${dict['url']}" in
        *'sourceforge.net/'*)
            ;;
        *)
            curl_args+=('--user-agent' "${dict['user_agent']}")
            ;;
    esac
    if [[ -z "${dict['output']}" ]]
    then
        dict['bn']="$(koopa_basename "${dict['url']}")"
        if koopa_str_detect_fixed --string="${dict['bn']}" --pattern='.'
        then
            dict['output']="${dict['bn']}"
            if koopa_str_detect_fixed \
                --pattern='%' \
                --string="${dict['output']}"
            then
                dict['output']="$( \
                    koopa_print "${dict['output']}" \
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
        else
            bool['remote_name']=1
        fi
    fi
    if [[ "${bool['remote_name']}" -eq 1 ]]
    then
        dict['output_dir']="${PWD:?}"
        curl_args+=(
            '--output-dir' "${dict['output_dir']}"
            '--remote-header-name'
            '--remote-name'
        )
        koopa_alert "Downloading '${dict['url']}' in '${dict['output_dir']}' \
using remote header name."
    else
        if ! koopa_str_detect_fixed --string="${dict['output']}" --pattern='/'
        then
            dict['output']="${PWD:?}/${dict['output']}"
        fi
        curl_args+=('--output' "${dict['output']}")
        koopa_alert "Downloading '${dict['url']}' to '${dict['output']}'."
    fi
    curl_args+=("${dict['url']}")
    "${app['curl']}" "${curl_args[@]}"
    if [[ "${bool['decompress']}" -eq 1 ]]
    then
        koopa_decompress "${dict['file']}"
    elif [[ "${bool['extract']}" -eq 1 ]]
    then
        koopa_extract "${dict['file']}"
    fi
    return 0
}
