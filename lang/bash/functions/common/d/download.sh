#!/usr/bin/env bash

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
    local -a curl_args curl_head_args pos
    koopa_assert_has_args "$#"
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['decompress']=0
    bool['extract']=0
    bool['progress']=1
    dict['user_agent']="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; \
rv:109.0) Gecko/20100101 Firefox/111.0"
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
    dict['file']="${2:-}"
    # FIXME This approach isn't working for Figshare URLs, need to debug.
    # FIXME This should redirect to target file name:
    # https://figshare.com/ndownloader/articles/24667905/versions/1
    # Should return '24667905.zip'.
    # We likely need to our agent in to avoid 502 Bad Gateway error.
    if [[ -z "${dict['file']}" ]]
    then
        dict['file']="$(koopa_basename "${dict['url']}")"
        # Attempt to get remote file name automatically for a URL that doesn't
        # contain an extension in the basename.
        if ! koopa_str_detect_fixed --string="${dict['file']}" --pattern='.'
        then
            curl_head_args+=(
                '--disable'
                '--head'
                '--silent'
            )
            case "${dict['url']}" in
                *'sourceforge.net/'*)
                    ;;
                *)
                    curl_head_args+=('--user-agent' "${dict['user_agent']}")
                    ;;
            esac
            curl_head_args+=("${dict['url']}")
            # Fetch the headers only. Note that curl returns these with
            # carriage return escapes '\r'.
            dict['head']="$("${app['curl']}" "${curl_head_args[@]}")"
            if koopa_str_detect_fixed \
                --string="${dict['head']}" \
                --pattern='X-Filename: '
            then
                app['cut']="$(koopa_locate_cut --allow-system)"
                koopa_assert_is_executable "${app['cut']}"
                dict['file']="$( \
                    koopa_grep \
                        --string="${dict['head']}" \
                        --pattern='X-Filename: ' \
                    | "${app['cut']}" -d ' ' -f 2 \
                    | koopa_sub \
                        --pattern='\r$' \
                        --regex \
                        --replacement='' \
                    | koopa_basename \
                )"
            fi
        fi
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
    if ! koopa_str_detect_fixed --string="${dict['file']}" --pattern='/'
    then
        dict['file']="${PWD:?}/${dict['file']}"
    fi
    # Inclusion of '--progress' shows a simple progress bar.
    curl_args+=(
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
            curl_args+=('--user-agent' "${dict['user_agent']}")
            ;;
    esac
    if [[ "${bool['progress']}" -eq 0 ]]
    then
        # Alternatively, can use '--no-progress-meter'.
        curl_args+=('--silent')
    fi
    curl_args+=("${dict['url']}")
    koopa_alert "Downloading '${dict['url']}' to '${dict['file']}'."
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
