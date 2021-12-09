#!/usr/bin/env bash

koopa::download() { # {{{1
    # """
    # Download a file.
    # @note Updated 2021-11-16.
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
    local app dict download_args
    koopa::assert_has_args_le "$#" 2
    declare -A dict=(
        [url]="${1:?}"
        [file]="${2:-}"
    )
    if koopa::is_qemu
    then
        dict[engine]='wget'
    else
        dict[engine]='curl'
    fi
    declare -A app=(
        [download]="$("koopa::locate_${dict[engine]}")"
    )
    if [[ -z "${dict[file]}" ]]
    then
        dict[file]="$(koopa::basename "${dict[url]}")"
    fi
    if ! koopa::str_match_fixed "${dict[file]}" '/'
    then
        dict[file]="$(pwd)/${dict[file]}"
    fi
    download_args=()
    case "${dict[engine]}" in
        'curl')
            download_args+=(
                '--disable'  # Ignore '~/.curlrc'. Must come first.
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
    koopa::alert "Downloading '${dict[url]}' to '${dict[file]}' \
using '${dict[engine]}'."
    "${app[download]}" "${download_args[@]}"
    return 0
}

koopa::download_cran_latest() { # {{{1
    # """
    # Download CRAN latest.
    # @note Updated 2021-10-25.
    # """
    local app file name pattern url
    koopa::assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa::locate_head)"
    )
    for name in "$@"
    do
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[-.0-9]+.tar.gz"
        file="$( \
            koopa::parse_url "$url" \
            | koopa::grep \
                --extended-regexp \
                --only-matching \
                "$pattern" \
            | "${app[head]}" -n 1 \
        )"
        koopa::download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}

koopa::download_github_latest() { # {{{1
    # """
    # Download GitHub latest release.
    # @note Updated 2021-10-25.
    # """
    local api_url app repo tag tarball_url
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [tr]="$(koopa::locate_tr)"
    )
    for repo in "$@"
    do
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            koopa::parse_url "$api_url" \
            | koopa::grep 'tarball_url' \
            | "${app[cut]}" -d ':' -f 2,3 \
            | "${app[tr]}" -d ' ,"' \
        )"
        tag="$(koopa::basename "$tarball_url")"
        koopa::download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}

# FIXME The refdata prefix doesn't currently work on macOS...need to put
# inside koopa instead?
koopa::download_refdata_scsig() { # {{{1
    # """
    # Download MSigDB SCSig reference data (now archived).
    # @note Updated 2021-12-09.
    #
    # @seealso
    # - https://www.gsea-msigdb.org/gsea/msigdb/supplementary_genesets.jsp
    # """
    local basename basenames dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [base_url]='http://software.broadinstitute.org/gsea/msigdb/supplemental'
        [name_fancy]='MSigDB SCSig'
        [refdata_prefix]="$(koopa::refdata_prefix)"
        [version]='1.0.1'
    )
    dict[prefix]="${dict[refdata_prefix]}/scsig/${dict[version]}"
    koopa::assert_is_not_dir "${dict[prefix]}"
    koopa::alert "Downloading ${dict[name_fancy]} ${dict[version]} \
to ${dict[prefix]}."
    koopa::mkdir "${dict[prefix]}"
    basenames=(
        "scsig.all.v${dict[version]}.entrez.gmt"
        "scsig.all.v${dict[version]}.symbols.gmt"
        "scsig.v${dict[version]}.metadata.txt"
        "scsig.v${dict[version]}.metadata.xls"
    )
    for basename in "${basenames[@]}"
    do
        koopa::download \
            "${dict[base_url]}/${basename}" \
            "${dict[prefix]}/${basename]}"
    done
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    koopa::alert_success "Download of ${dict[name_fancy]} to \
${dict[prefix]} was successful."
    return 0
}

koopa::download_sra_accession_list() { # {{{1
    # """
    # Download SRA accession list.
    # @note Updated 2021-10-25.
    # """
    local app file id
    koopa::assert_has_args_le "$#" 2
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [sed]="$(koopa::locate_sed)"
    )
    koopa::activate_conda_env 'entrez-direct'
    koopa::assert_is_installed 'esearch' 'efetch'
    id="${1:?}"
    file="${2:-SraAccList.txt}"
    koopa::alert "Downloading SRA '${id}' to '${file}'."
    esearch -db sra -q "$id" \
        | efetch -format 'runinfo' \
        | "${app[sed]}" '1d' \
        | "${app[cut]}" -d ',' -f 1 \
        > "$file"
    koopa::deactivate_conda
    return 0
}

# FIXME Need to rework using dict approach.
koopa::download_sra_run_info_table() { # {{{1
    # """
    # Download SRA run info table.
    # @note Updated 2021-10-25.
    # """
    koopa::assert_has_args_le "$#" 2
    koopa::activate_conda_env 'entrez-direct'
    koopa::assert_is_installed 'esearch' 'efetch'
    id="${1:?}"
    file="${2:-SraRunTable.txt}"
    koopa::alert "Downloading SRA '${id}' to '${file}'."
    esearch -db sra -q "$id" \
        | efetch -format runinfo \
        > "$file"
    koopa::deactivate_conda
    return 0
}

# FIXME Rework this using dict approach.
koopa::ftp_mirror() { # {{{1
    # """
    # Mirror contents from an FTP server.
    # @note Updated 2021-12-09.
    # """
    local dir host user wget
    koopa::assert_has_args "$#"
    wget="$(koopa::locate_wget)"
    dir=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--dir='*)
                dir="${1#*=}"
                shift 1
                ;;
            '--dir')
                dir="${2:?}"
                shift 2
                ;;
            '--host='*)
                host="${1#*=}"
                shift 1
                ;;
            '--host')
                host="${2:?}"
                shift 2
                ;;
            '--user='*)
                user="${1#*=}"
                shift 1
                ;;
            '--user')
                user="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--host' "$host" \
        '--user' "$user"
    if [[ -n "$dir" ]]
    then
        dir="${host}/${dir}"
    else
        dir="${host}"
    fi
    "$wget" --ask-password --mirror "ftp://${user}@${dir}/"*
    return 0
}

# FIXME Rework using dict approach.
koopa::parse_url() { # {{{1
    # """
    # Parse a URL using cURL.
    # @note Updated 2021-11-02.
    # """
    local curl curl_args pos url
    koopa::assert_has_args "$#"
    curl="$(koopa::locate_curl)"
    curl_args=(
        '--disable'  # Ignore '~/.curlrc'. Must come first.
        '--fail'
        '--location'
        '--retry' 5
        '--show-error'
        '--silent'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--insecure' | \
            '--list-only')
                curl_args+=("$1")
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_eq "$#" 1
    url="${1:?}"
    # NOTE Don't use 'koopa::print' here, since we need to pass binary output
    # in some cases for GPG key configuration.
    "$curl" "${curl_args[@]}" "$url"
    return 0
}

# FIXME Rework using dict approach.
koopa::wget_recursive() { # {{{1
    # """
    # Download files with wget recursively.
    # @note Updated 2021-05-24.
    #
    # Note that we need to escape the wildcards in the password.
    # For direct input, can just use single quotes to escape.
    # See also: https://unix.stackexchange.com/questions/379181
    # """
    local datetime log_file name password url user wget wget_args
    koopa::assert_has_args_eq "$#" 3
    wget="$(koopa::locate_wget)"
    url="${1:?}"
    user="${2:?}"
    password="${3:?}"
    password="${password@Q}"
    datetime="$(koopa::datetime)"
    log_file="wget-${datetime}.log"
    wget_args=(
        "--output-file=${log_file}"
        "--password=${password}"
        "--user=${user}"
        '--continue'
        '--debug'
        '--no-parent'
        '--recursive'
    )
    "$wget" "${wget_args[@]}" "$url"/*
    return 0
}
