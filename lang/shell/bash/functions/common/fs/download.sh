#!/usr/bin/env bash

koopa::download() { # {{{1
    # """
    # Download a file.
    # @note Updated 2021-05-06.
    #
    # Potentially useful curl flags:
    # * --connect-timeout <seconds>
    # * --progress-bar
    # * --silent
    # * --stderr
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    local bn brew_curl brew_prefix curl curl_args file url wd
    koopa::assert_has_args "$#"
    url="${1:?}"
    file="${2:-}"
    if [[ -z "$file" ]]
    then
        wd="$(pwd)"
        bn="$(basename "$url")"
        file="${wd}/${bn}"
    fi
    file="$(koopa::realpath "$file")"
    curl='curl'
    # Switch to Homebrew cURL on macOS, if possible.
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        brew_curl="${brew_prefix}/opt/curl/bin/curl"
        [[ -x "$brew_curl" ]] && curl="$brew_curl"
    fi
    koopa::assert_is_installed "$curl"
    curl_args=(
        '--create-dirs'
        '--fail'
        '--location'
        '--output' "$file"
        '--retry' 5
        '--show-error'
    )
    curl_args+=("$url")
    koopa::alert "Downloading '${url}' to '${file}'."
    "$curl" "${curl_args[@]}"
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
    # @note Updated 2020-07-11.
    # """
    local repo tag tarball_url
    koopa::assert_has_args "$#"
    for repo in "$@"
    do
        tarball_url="$( \
            curl -s "https://api.github.com/repos/${repo}/releases/latest" \
            | grep 'tarball_url' \
            | cut -d ':' -f 2,3 \
            | tr -d ' ,"' \
        )"
        tag="$(basename "$tarball_url")"
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

koopa::sra_prefetch_parallel() { # {{{1
    koopa::assert_is_installed ascp find parallel prefetch
    koopa::assert_is_file SRRAccList.txt
    file="${1:-SraAccList.txt}"
    jobs="$(koopa::cpu_count)"
    find . \(-name '*.lock' -o -name '*.tmp'\) -delete
    sort -u "$file" | parallel -j "$jobs" 'prefetch --verbose {}'
    return 0
}

koopa::wget_recursive() { # {{{1
    # """
    # Download files with wget recursively.
    # @note Updated 2020-07-13.
    #
    # Note that we need to escape the wildcards in the password.
    # For direct input, can just use single quotes to escape.
    # See also: https://unix.stackexchange.com/questions/379181
    # """
    local datetime log_file password url user
    koopa::assert_has_args_eq "$#" 3
    koopa::assert_is_installed wget
    url="${1:?}"
    user="${2:?}"
    password="${3:?}"
    password="${password@Q}"
    datetime="$(koopa::datetime)"
    log_file="wget-${datetime}.log"
    wget \
        --continue \
        --debug \
        --no-parent \
        --output-file="$log_file" \
        --password="$password" \
        --recursive \
        --user="$user" \
        "$url"/*
    return 0
}
