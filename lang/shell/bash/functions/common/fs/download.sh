#!/usr/bin/env bash

koopa::download() { # {{{1
    # """
    # Download a file.
    # @note Updated 2021-05-21.
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
    local bn dl dl_args file url wd
    koopa::assert_has_args "$#"
    url="${1:?}"
    file="${2:-}"
    if [[ -z "$file" ]]
    then
        wd="$(pwd)"
        bn="$(koopa::basename "$url")"
        file="${wd}/${bn}"
    fi
    dl='curl'
    koopa::is_qemu && dl='wget'
    dl_args=()
    case "$dl" in
        curl)
            dl_args+=(
                '--disable'  # Ignore the '~/.curlrc' file. Must come first!
                '--create-dirs'
                '--fail'
                '--location'
                '--output' "$file"
                '--retry' 5
                '--show-error'
            )
            ;;
        wget)
            dl_args+=(
                "--output-document=${file}"
                '--no-verbose'
            )
            ;;
    esac
    koopa::alert "Downloading '${url}' to '${file}'."
    dl="$("koopa::locate_${dl}")"
    dl_args+=("$url")
    "$dl" "${dl_args[@]}"
    return 0
}

koopa::download_cran_latest() { # {{{1
    # """
    # Download CRAN latest.
    # @note Updated 2020-07-11.
    # """
    local name pattern url
    koopa::assert_has_args "$#"
    koopa::assert_is_installed curl grep head
    for name in "$@"
    do
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[.0-9]+.tar.gz"
        file="$(curl --silent "$url" | grep -Eo "$pattern" | head -n 1)"
        koopa::download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}

koopa::download_github_latest() { # {{{1
    # """
    # Download GitHub latest release.
    # @note Updated 2021-05-20.
    # """
    local api_url curl cut grep repo tag tarball_url tr
    koopa::assert_has_args "$#"
    basename="$(koopa::locate_basename)"
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    tr="$(koopa::locate_tr)"
    for repo in "$@"
    do
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            "$curl" -s "$api_url" \
            | "$grep" 'tarball_url' \
            | "$cut" -d ':' -f 2,3 \
            | "$tr" -d ' ,"' \
        )"
        tag="$("$basename" "$tarball_url")"
        koopa::download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}

koopa::download_refdata_scsig() { # {{{1
    # """
    # Download MSigDB SCSig reference data.
    # @note Updated 2020-07-30.
    # """
    local base_url prefix version
    koopa::assert_has_no_args "$#"
    version='1.0'
    prefix="$(koopa::refdata_prefix)/scsig/${version}"
    base_url='http://software.broadinstitute.org/gsea/msigdb/supplemental'
    [[ -d "$prefix" ]] && return 0
    koopa::h1 "Downloading MSigDB SCSig ${version}."
    koopa::mkdir "$prefix"
    (
        koopa::cd "$prefix"
        koopa::download "${base_url}/scsig.all.v${version}.symbols.gmt"
        koopa::download "${base_url}/scsig.all.v${version}.entrez.gmt"
        koopa::download "${base_url}/scsig.v${version}.metadata.xls"
        koopa::download "${base_url}/scsig.v${version}.metadata.txt"
    )
    koopa::sys_set_permissions -r "$prefix"
    koopa::alert_success 'Download of SCSig was successful.'
    return 0
}

koopa::download_sra_accession_list() { # {{{1
    # """
    # Download SRA accession list.
    # @note Updated 2020-07-02.
    # """
    local file id
    koopa::assert_has_args_le "$#" 2
    koopa::activate_conda_env entrez-direct
    koopa::assert_is_installed esearch efetch
    id="${1:?}"
    file="${2:-SraAccList.txt}"
    koopa::h1 "Downloading SRA '${id}' to '${file}'."
    esearch -db sra -q "$id" \
        | efetch -format runinfo \
        | sed 1d \
        | cut -d ',' -f 1 \
        > "$file"
    return 0
}

koopa::download_sra_run_info_table() { # {{{1
    # """
    # Download SRA run info table.
    # @note Updated 2020-07-02.
    # """
    koopa::activate_conda_env entrez-direct
    koopa::assert_is_installed esearch efetch
    id="${1:?}"
    file="${2:-SraRunTable.txt}"
    koopa::h1 "Downloading SRA '${id}' to '${file}'."
    esearch -db sra -q "$id" \
        | efetch -format runinfo \
        > "$file"
    return 0
}

koopa::ftp_mirror() { # {{{1
    local dir host user
    koopa::assert_has_args "$#"
    koopa::assert_is_installed wget
    dir=''
    while (("$#"))
    do
        case "$1" in
            --dir=*)
                dir="${1#*=}"
                shift 1
                ;;
            --host=*)
                host="${1#*=}"
                shift 1
                ;;
            --user=*)
                user="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set host user
    if [[ -n "$dir" ]]
    then
        dir="${host}/${dir}"
    else
        dir="${host}"
    fi
    wget --ask-password --mirror "ftp://${user}@${dir}/"*
    return 0
}

koopa::wget_recursive() { # {{{1
    # """
    # Download files with wget recursively.
    # @note Updated 2021-05-20.
    #
    # Note that we need to escape the wildcards in the password.
    # For direct input, can just use single quotes to escape.
    # See also: https://unix.stackexchange.com/questions/379181
    # """
    local brew_prefix datetime log_file name password url user wget wget_args
    koopa::assert_has_args_eq "$#" 3
    wget='wget'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        wget="${brew_prefix}/bin/wget"
    fi
    koopa::assert_is_installed "$wget"
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
