#!/usr/bin/env bash

koopa_download() {
    # """
    # Download a file.
    # @note Updated 2022-04-15.
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
    #
    # @examples
    # > koopa_download 'ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE69nnn/GSE69740/suppl/GSE69740%5FRPKM%2Etxt%2Egz'
    # """
    local app dict download_args pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [decompress]=0
        [extract]=0
        [engine]='curl'
        [file]="${2:-}"
        [url]="${1:?}"
    )
    koopa_is_qemu && dict[engine]='wget'
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--engine='*)
                dict[engine]="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict[engine]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--decompress')
                dict[decompress]=1
                shift 1
                ;;
            '--extract')
                dict[extract]=1
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
    declare -A app=(
        [download]="$("koopa_locate_${dict[engine]}")"
    )
    if [[ -z "${dict[file]}" ]]
    then
        dict[file]="$(koopa_basename "${dict[url]}")"
        if koopa_str_detect_fixed --string="${dict[file]}" --pattern='%'
        then
            dict[file]="$( \
                koopa_print "${dict[file]}" \
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
        --string="${dict[file]}" \
        --pattern='/'
    then
        dict[file]="${PWD:?}/${dict[file]}"
    fi
    download_args=()
    case "${dict[engine]}" in
        'curl')
            download_args+=(
                '--disable' # Ignore '~/.curlrc'. Must come first.
                '--create-dirs'
                '--fail'
                '--location'
                '--output' "${dict[file]}"
                '--retry' 5
                '--show-error'
            )
            ;;
        'wget')
            download_args+=(
                "--output-document=${dict[file]}"
                '--no-verbose'
            )
            ;;
    esac
    download_args+=("${dict[url]}")
    koopa_alert "Downloading '${dict[url]}' to '${dict[file]}'."
    "${app[download]}" "${download_args[@]}"
    if [[ "${dict[decompress]}" -eq 1 ]]
    then
        koopa_decompress "${dict[file]}"
    elif [[ "${dict[extract]}" -eq 1 ]]
    then
        koopa_extract "${dict[file]}"
    fi
    return 0
}
