#!/usr/bin/env bash

koopa_download() {
    # """
    # Download a file.
    # @note Updated 2024-06-11.
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
    local -a curl_args
    koopa_assert_has_args_le "$#" 2
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['progress']=1
    dict['user_agent']="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; \
rv:120.0) Gecko/20100101 Firefox/120.0"
    dict['url']="${1:?}"
    dict['file']="${2:-}"
    # Inclusion of '--progress' shows a simpler progress bar.
    curl_args+=(
        '--disable' # Ignore '~/.curlrc'. Must come first.
        '--create-dirs'
        '--fail'
        # Not ideal but this plays nice with corporate gateways.
        '--insecure'
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
    if [[ -z "${dict['file']}" ]]
    then
        dict['bn']="$(koopa_basename "${dict['url']}")"
        if koopa_str_detect_fixed --string="${dict['bn']}" --pattern='.'
        then
            dict['file']="${dict['bn']}"
            if koopa_str_detect_fixed \
                --pattern='%' \
                --string="${dict['file']}"
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
    fi
    if [[ -n "${dict['file']}" ]]
    then
        if ! koopa_str_detect_fixed --string="${dict['file']}" --pattern='/'
        then
            dict['file']="${PWD:?}/${dict['file']}"
        fi
        curl_args+=('--output' "${dict['file']}")
        koopa_alert "Downloading '${dict['url']}' to '${dict['file']}'."
    else
        dict['output_dir']="${PWD:?}"
        curl_args+=(
            '--output-dir' "${dict['output_dir']}"
            '--remote-header-name'
            '--remote-name'
        )
        koopa_alert "Downloading '${dict['url']}' in '${dict['output_dir']}' \
using remote header name."
    fi
    curl_args+=("${dict['url']}")
    "${app['curl']}" "${curl_args[@]}"
    if [[ -n "${dict['file']}" ]]
    then
        koopa_assert_is_file "${dict['file']}"
    fi
    return 0
}
