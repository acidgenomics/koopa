#!/usr/bin/env bash

koopa::download() { # {{{1
    # """
    # Download a file.
    # @note Updated 2020-07-05.
    #
    # Potentially useful curl flags:
    # * --connect-timeout <seconds>
    # * --silent
    # * --stderr
    # * --verbose
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    local bn file url wd
    koopa::assert_has_args "$#"
    koopa::assert_is_installed curl
    url="${1:?}"
    file="${2:-}"
    if [[ -z "$file" ]]
    then
        wd="$(pwd)"
        bn="$(basename "$url")"
        file="${wd}/${bn}"
    fi
    file="$(realpath "$file")"
    koopa::info "Downloading '${url}' to '${file}'."
    curl \
        --create-dirs \
        --fail \
        --location \
        --output "$file" \
        --progress-bar \
        --retry 5 \
        --show-error \
        "$url"
    return 0
}

koopa::download_cran_latest() {
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

koopa::download_github_latest() {
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

koopa::download_refdata_scsig() {
    local base_url prefix version
    koopa::assert_has_no_args "$#"
    version='1.0'
    prefix="$(koopa::refdata_prefix)/scsig/${version}"
    base_url='http://software.broadinstitute.org/gsea/msigdb/supplemental'
    koopa::exit_if_dir "$prefix"
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
    koopa::success 'Download of SCSig was successful.'
    return 0
}

koopa::download_sra_accession_list() {
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

koopa::download_sra_run_info_table() {
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

koopa::ftp_mirror() {
    local dir host user
    koopa::assert_has_args "$#"
    koopa::assert_is_installed wget
    dir=
    while (("$#"))
    do
        case "$1" in
            --dir=*)
                dir="${1#*=}"
                shift 1
                ;;
            --dir)
                dir="$2"
                shift 2
                ;;
            --host=*)
                host="${1#*=}"
                shift 1
                ;;
            --host)
                host="$2"
                shift 2
                ;;
            --user=*)
                user="${1#*=}"
                shift 1
                ;;
            --user)
                user="$2"
                shift 2
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

koopa::sra_prefetch_parallel() {
    koopa::assert_is_installed ascp find parallel prefetch
    koopa::assert_is_file SRRAccList.txt
    file="${1:-SraAccList.txt}"
    jobs="$(koopa::cpu_count)"
    find . \(-name '*.lock' -o -name '*.tmp'\) -delete
    sort -u "$file" | parallel -j "$jobs" 'prefetch --verbose {}'
    return 0
}

koopa::wget_recursive() {
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

koopa::youtube_mp3() {
    # """
    # Download MP3 audio from YouTube, Soundcloud, Mixcloud, etc.
    # @note Updated 2020-07-04.
    # """
    local url
    koopa::assert_has_args "$#"
    koopa::assert_is_installed youtube-dl
    for url in "$@"
    do
        youtube-dl --extract-audio --audio-format mp3 "$url"
    done
    return 0
}

koopa::youtube_thumbnail() {
    # """
    # Download a thumbnail image from YouTube.
    # @note Updated 2020-07-04.
    #
    # File options:
    # - hqdefault (smaller)
    # - maxresdefault (larger)
    #
    # Not all videos will return max res thumbnail, so stick with hq instead.
    # """
    local id url
    koopa::assert_has_args "$#"
    for url in "$@"
    do
        id="$( \
            koopa::print "$url" \
                | grep -Eo 'v=[A-Za-z0-9_-]+' \
                | cut -d '=' -f 2 \
        )"
        koopa::download "https://i.ytimg.com/vi/${id}/hqdefault.jpg" "${id}.jpg"
    done
    return 0
}

