#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2026-07-14.
# """

set -o errexit
set -o nounset
KOOPA_VERBOSE="${KOOPA_VERBOSE:-0}"
if [ "$KOOPA_VERBOSE" -eq 1 ] 2>/dev/null
then
    set -o xtrace
    _make_verbose='VERBOSE=1'
    _curl_verbose='--verbose'
else
    _make_verbose=''
    _curl_verbose='--progress-bar'
fi

is_macos() {
    [ "$(uname -s)" = 'Darwin' ]
}

is_amd64() {
    [ "$(uname -m)" = 'x86_64' ]
}

is_arm64() {
    case "$(uname -m)" in
        'aarch64' | 'arm64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

cpu_count() {
    # Precedence: an explicit Slurm allocation (SLURM_CPUS_PER_TASK, then
    # SLURM_CPUS_ON_NODE) beats a possibly stale inherited KOOPA_CPU_COUNT,
    # which beats an affinity-aware nproc probe, which beats getconf/sysctl/
    # python. Each candidate is accepted only when it parses as a positive
    # integer -- Slurm also exports 'SLURM_JOB_CPUS_PER_NODE', but in a
    # compressed multi-node form such as '4(x2)' that must never reach
    # 'make --jobs' verbatim, so that name is deliberately not read here.
    #
    # The affinity-aware nproc result also clamps the final value: koopa must
    # never spawn more build jobs than the current CPU allocation, even when
    # a Slurm variable or KOOPA_CPU_COUNT claims otherwise.
    __kvar_num=''
    for __kvar_candidate in \
        "${SLURM_CPUS_PER_TASK:-}" \
        "${SLURM_CPUS_ON_NODE:-}" \
        "${KOOPA_CPU_COUNT:-}"
    do
        case "$__kvar_candidate" in
            '' | *[!0-9]*) continue ;;
        esac
        __kvar_num="$__kvar_candidate"
        break
    done
    unset -v __kvar_candidate
    if [ -d "${KOOPA_PREFIX:-}" ]
    then
        __kvar_bin_prefix="${KOOPA_PREFIX:?}/bin"
    else
        __kvar_bin_prefix=''
    fi
    __kvar_getconf='/usr/bin/getconf'
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/gnproc" ]
    then
        __kvar_nproc="${__kvar_bin_prefix}/gnproc"
    else
        __kvar_nproc=''
    fi
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/python3" ]
    then
        __kvar_python="${__kvar_bin_prefix}/python3"
    elif [ -x '/usr/bin/python3' ]
    then
        __kvar_python='/usr/bin/python3'
    else
        __kvar_python=''
    fi
    __kvar_sysctl='/usr/sbin/sysctl'
    __kvar_avail=''
    if [ -x "$__kvar_nproc" ]
    then
        # No '--all': bare nproc honors the CPU affinity mask (e.g. a Slurm
        # cgroup), which is exactly the value 'make --jobs' must respect.
        __kvar_avail="$("$__kvar_nproc")"
        case "$__kvar_avail" in
            '' | *[!0-9]*) __kvar_avail='' ;;
        esac
    fi
    if [ -n "$__kvar_num" ] && [ -n "$__kvar_avail" ] \
        && [ "$__kvar_num" -gt "$__kvar_avail" ]
    then
        __kvar_num="$__kvar_avail"
    fi
    if [ -z "$__kvar_num" ]
    then
        if [ -n "$__kvar_avail" ]
        then
            __kvar_num="$__kvar_avail"
        elif [ -x "$__kvar_getconf" ]
        then
            __kvar_num="$("$__kvar_getconf" '_NPROCESSORS_ONLN')"
        elif [ -x "$__kvar_sysctl" ] && is_macos
        then
            __kvar_num="$("$__kvar_sysctl" -n 'hw.ncpu')"
        elif [ -x "$__kvar_python" ]
        then
            __kvar_num="$( \
                "$__kvar_python" -c \
                    "import multiprocessing; print(multiprocessing.cpu_count())" \
                2>/dev/null \
                || true \
            )"
        fi
    fi
    [ -z "$__kvar_num" ] && __kvar_num=1
    printf '%d\n' "$__kvar_num"
    unset -v \
        __kvar_avail \
        __kvar_bin_prefix \
        __kvar_getconf \
        __kvar_nproc \
        __kvar_num \
        __kvar_python \
        __kvar_sysctl
    return 0
}

# ---------------------------------------------------------------------------
# Vendor mirror support ('${XDG_CONFIG_HOME:-~/.config}/koopa/vendor.json',
# falling back to 'etc/koopa/vendor.json'). See docs/installation.md,
# "Internal mirror (restricted networks)", and koopa.vendor for the Python
# equivalent that koopa itself uses once bootstrapped. Kept in sync by hand;
# lang/python/tests/test_bootstrap.py asserts the sh and Python helpers agree.
# ---------------------------------------------------------------------------

_vendor_parse_json() {
    # usage: _vendor_parse_json <python3-bin> <vendor.json-path> <out-file>
    # Writes 'key<TAB>value' lines (a 'remote' key has two tab-separated
    # values: host and repo) to <out-file>. Any Python 3 can parse JSON, so
    # this does not require the .python-version-pinned interpreter.
    # NOTE: uses the '__kvpj_' prefix, not the caller vendor_load()'s
    # '__kvar_', because vendor_load() passes its own __kvar_out as our
    # <out-file> argument -- reusing '__kvar_' here would make our final
    # 'unset -v' wipe that still-needed caller variable out from under it.
    __kvpj_py_bin="${1:?}"
    __kvpj_path="${2:?}"
    __kvpj_out="${3:?}"
    __kvpj_py="$(mktemp -t koopa-vendor-parse-XXXXXX.py)"
    cat > "$__kvpj_py" << 'VENDOR_PARSE_PY_EOF'
import json
import sys


def emit(key, value):
    value = str(value).replace("\t", " ").replace("\n", " ")
    sys.stdout.write(f"{key}\t{value}\n")


path = sys.argv[1]
try:
    with open(path) as f:
        data = json.load(f)
except (OSError, ValueError):
    sys.exit(0)
if not isinstance(data, dict) or not data.get("enabled", False):
    sys.exit(0)
backend = data.get("backend", "")
if backend not in ("http", "s3"):
    sys.exit(0)
emit("enabled", "1")
emit("backend", backend)
emit("pull_priority", data.get("pull_priority", "vendor_first"))
if backend == "http":
    hc = data.get("http", {})
    if not isinstance(hc, dict):
        hc = {}
    emit("base_url", hc.get("base_url", ""))
    emit("src_repo", hc.get("src_repo", ""))
    emit("token_env_var", hc.get("token_env_var", "HTTP_ACCESS_TOKEN"))
    remotes = hc.get("remotes", {})
    if isinstance(remotes, dict):
        for host, repo in remotes.items():
            if isinstance(host, str) and isinstance(repo, str):
                host = host.replace("\t", " ").replace("\n", " ")
                repo = repo.replace("\t", " ").replace("\n", " ")
                sys.stdout.write(f"remote\t{host}\t{repo}\n")
else:
    sc = data.get("s3", {})
    if not isinstance(sc, dict):
        sc = {}
    emit("s3_bucket", sc.get("bucket", ""))
    emit("s3_profile", sc.get("profile", ""))
    emit("s3_src_prefix", sc.get("src_prefix", "src"))
VENDOR_PARSE_PY_EOF
    "$__kvpj_py_bin" "$__kvpj_py" "$__kvpj_path" > "$__kvpj_out" 2>/dev/null || true
    rm -f "$__kvpj_py"
    unset -v __kvpj_out __kvpj_path __kvpj_py __kvpj_py_bin
}

_vendor_sed_fallback() {
    # usage: _vendor_sed_fallback <vendor.json-path>
    # Degraded parse used only when no python3 is available at all. Handles
    # the six flat scalar fields; the nested 'remotes' map needs a real JSON
    # parser and is unavailable here (see vendor_load()). Every pattern
    # anchors on the key starting the line (after whitespace), so the
    # "_comment" field's prose -- which contains the words "enabled" and
    # "backend" -- is never mistaken for the real keys.
    __kvsf_f="${1:?}"
    __kvsf_enabled="$( \
        sed -n -E 's/^[[:space:]]*"enabled"[[:space:]]*:[[:space:]]*(true|false).*/\1/p' \
            "$__kvsf_f" \
        | head -1 \
    )"
    if [ "$__kvsf_enabled" != 'true' ]
    then
        unset -v __kvsf_enabled __kvsf_f
        return 0
    fi
    printf 'enabled\t1\n'
    printf 'backend\t%s\n' "$( \
        sed -n -E 's/^[[:space:]]*"backend"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' \
            "$__kvsf_f" \
        | head -1 \
    )"
    printf 'pull_priority\t%s\n' "$( \
        sed -n -E 's/^[[:space:]]*"pull_priority"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' \
            "$__kvsf_f" \
        | head -1 \
    )"
    printf 'base_url\t%s\n' "$( \
        sed -n -E 's/^[[:space:]]*"base_url"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' \
            "$__kvsf_f" \
        | head -1 \
    )"
    printf 'src_repo\t%s\n' "$( \
        sed -n -E 's/^[[:space:]]*"src_repo"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' \
            "$__kvsf_f" \
        | head -1 \
    )"
    printf 'token_env_var\t%s\n' "$( \
        sed -n -E 's/^[[:space:]]*"token_env_var"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' \
            "$__kvsf_f" \
        | head -1 \
    )"
    unset -v __kvsf_enabled __kvsf_f
}

_vendor_env_value() {
    # usage: _vendor_env_value <env-var-name>
    # Prints the value of the named environment variable, or nothing if the
    # name is not a valid identifier, printenv is unavailable, or it is
    # unset. Never uses eval: <name> comes from vendor.json, and this keeps
    # it from ever being interpreted as shell code.
    __kvev_name="${1:-}"
    case "$__kvev_name" in
        '' | *[!A-Za-z0-9_]*)
            unset -v __kvev_name
            return 0
            ;;
    esac
    if command -v printenv > /dev/null 2>&1
    then
        printenv "$__kvev_name" 2>/dev/null || true
    fi
    unset -v __kvev_name
}

vendor_load() {
    # Populates the VENDOR_* globals, once, at the top of main(). Checked in
    # order, first existing file wins (not merged):
    # '${XDG_CONFIG_HOME:-~/.config}/koopa/vendor.json', then
    # '${KOOPA_PREFIX}/etc/koopa/vendor.json' -- matching
    # koopa.vendor.vendor_config()'s search order. Leaves VENDOR_ENABLED=0
    # (all vendor lookups become no-ops) when neither file exists, or the one
    # found is disabled or invalid, matching vendor_config()'s None case.
    VENDOR_ENABLED=0
    VENDOR_BACKEND=''
    VENDOR_BASE_URL=''
    VENDOR_SRC_REPO=''
    VENDOR_TOKEN_ENV_VAR='HTTP_ACCESS_TOKEN'
    VENDOR_TOKEN=''
    VENDOR_PULL_PRIORITY='vendor_first'
    VENDOR_S3_BUCKET=''
    VENDOR_S3_PROFILE=''
    VENDOR_S3_SRC_PREFIX='src'
    VENDOR_REMOTES=''
    __kvar_json="${XDG_CONFIG_HOME:-${HOME}/.config}/koopa/vendor.json"
    if [ ! -f "$__kvar_json" ]
    then
        __kvar_json="${KOOPA_PREFIX}/etc/koopa/vendor.json"
    fi
    if [ ! -f "$__kvar_json" ]
    then
        unset -v __kvar_json
        return 0
    fi
    __kvar_py_bin=''
    if command -v python3 > /dev/null 2>&1 && python3 -c 'pass' 2>/dev/null
    then
        __kvar_py_bin='python3'
    elif [ -x /usr/bin/python3 ] && /usr/bin/python3 -c 'pass' 2>/dev/null
    then
        __kvar_py_bin='/usr/bin/python3'
    fi
    __kvar_out="$(mktemp -t koopa-vendor-XXXXXX)"
    if [ -n "$__kvar_py_bin" ]
    then
        _vendor_parse_json "$__kvar_py_bin" "$__kvar_json" "$__kvar_out"
    else
        _vendor_sed_fallback "$__kvar_json" > "$__kvar_out"
    fi
    while IFS='	' read -r __kvar_k __kvar_v1 __kvar_v2
    do
        case "$__kvar_k" in
            enabled) VENDOR_ENABLED="$__kvar_v1" ;;
            backend) VENDOR_BACKEND="$__kvar_v1" ;;
            base_url) VENDOR_BASE_URL="$__kvar_v1" ;;
            src_repo) VENDOR_SRC_REPO="$__kvar_v1" ;;
            token_env_var)
                [ -n "$__kvar_v1" ] && VENDOR_TOKEN_ENV_VAR="$__kvar_v1"
                ;;
            pull_priority) VENDOR_PULL_PRIORITY="$__kvar_v1" ;;
            s3_bucket) VENDOR_S3_BUCKET="$__kvar_v1" ;;
            s3_profile) VENDOR_S3_PROFILE="$__kvar_v1" ;;
            s3_src_prefix)
                [ -n "$__kvar_v1" ] && VENDOR_S3_SRC_PREFIX="$__kvar_v1"
                ;;
            remote)
                VENDOR_REMOTES="${VENDOR_REMOTES}${__kvar_v1}	${__kvar_v2}
"
                ;;
        esac
    done < "$__kvar_out"
    rm -f "$__kvar_out"
    if [ -z "$__kvar_py_bin" ] && [ "$VENDOR_BACKEND" = 's3' ]
    then
        printf 'Warning: vendor backend is "s3" but no python3 is available to parse vendor.json fully; disabling the vendor mirror for this run.\n' >&2
        VENDOR_ENABLED=0
        VENDOR_BACKEND=''
    fi
    if [ "$VENDOR_ENABLED" = '1' ]
    then
        VENDOR_TOKEN="$(_vendor_env_value "$VENDOR_TOKEN_ENV_VAR")"
    fi
    unset -v __kvar_json __kvar_k __kvar_out __kvar_py_bin __kvar_v1 __kvar_v2
    return 0
}

vendor_src_url() {
    # usage: vendor_src_url <name> <filename>
    # Mirrors koopa.vendor._http_src_url(): {base}/{repo}/src/{name}/{filename}.
    __kvsu_name="${1:?}"
    __kvsu_filename="${2:?}"
    if [ "$VENDOR_ENABLED" = '1' ] && [ "$VENDOR_BACKEND" = 'http' ] \
        && [ -n "$VENDOR_BASE_URL" ] && [ -n "$VENDOR_SRC_REPO" ]
    then
        printf '%s/%s/src/%s/%s\n' \
            "${VENDOR_BASE_URL%/}" "$VENDOR_SRC_REPO" "$__kvsu_name" "$__kvsu_filename"
    fi
    unset -v __kvsu_filename __kvsu_name
    return 0
}

vendor_rewrite_url() {
    # usage: vendor_rewrite_url <url>
    # Mirrors koopa.vendor.vendor_rewrite_url(): rewrites <url> through a
    # vendor remote-proxy repo matched by hostname (exact, then a '.suffix'
    # match against VENDOR_REMOTES), or prints nothing if unmatched.
    __kvru_url="${1:?}"
    if [ "$VENDOR_ENABLED" != '1' ] || [ "$VENDOR_BACKEND" != 'http' ] || [ -z "$VENDOR_REMOTES" ]
    then
        unset -v __kvru_url
        return 0
    fi
    __kvru_host="$( \
        printf '%s\n' "$__kvru_url" \
        | sed -E 's#^[a-zA-Z][a-zA-Z0-9+.-]*://([^/]*).*#\1#' \
    )"
    __kvru_host="${__kvru_host#*@}"
    __kvru_host="${__kvru_host%%:*}"
    __kvru_repo=''
    __kvru_rest="$VENDOR_REMOTES"
    while [ -n "$__kvru_rest" ]
    do
        __kvru_line="${__kvru_rest%%
*}"
        case "$__kvru_rest" in
            *"
"*) __kvru_rest="${__kvru_rest#*
}" ;;
            *) __kvru_rest='' ;;
        esac
        __kvru_rhost="${__kvru_line%	*}"
        __kvru_rrepo="${__kvru_line#*	}"
        [ -n "$__kvru_rhost" ] || continue
        if [ "$__kvru_rhost" = "$__kvru_host" ]
        then
            __kvru_repo="$__kvru_rrepo"
            break
        fi
        case "$__kvru_rhost" in
            .*)
                case "$__kvru_host" in
                    *"$__kvru_rhost")
                        __kvru_repo="$__kvru_rrepo"
                        break
                        ;;
                esac
                ;;
        esac
    done
    if [ -n "$__kvru_repo" ]
    then
        __kvru_path="${__kvru_url#*://}"
        __kvru_path="${__kvru_path#*/}"
        printf '%s/%s/%s\n' "${VENDOR_BASE_URL%/}" "$__kvru_repo" "$__kvru_path"
    fi
    unset -v __kvru_host __kvru_line __kvru_path __kvru_repo __kvru_rest __kvru_rhost __kvru_rrepo __kvru_url
    return 0
}

vendor_urls_for() {
    # usage: vendor_urls_for <name> <filename>
    # Prints the vendor src-mirror candidate for <name>/<filename>: a URL
    # for the http backend, or an 's3://' URI (which download_with_fallback
    # fetches via 'aws s3 cp' instead of curl) for the s3 backend. Prints
    # nothing if vendor is disabled or the backend lacks the needed fields.
    __kvuf_name="${1:?}"
    __kvuf_filename="${2:?}"
    if [ "$VENDOR_ENABLED" = '1' ]
    then
        case "$VENDOR_BACKEND" in
            http) vendor_src_url "$__kvuf_name" "$__kvuf_filename" ;;
            s3)
                if [ -n "$VENDOR_S3_BUCKET" ]
                then
                    printf 's3://%s/%s/%s/%s\n' \
                        "$VENDOR_S3_BUCKET" "${VENDOR_S3_SRC_PREFIX:-src}" \
                        "$__kvuf_name" "$__kvuf_filename"
                fi
                ;;
        esac
    fi
    unset -v __kvuf_filename __kvuf_name
    return 0
}

vendor_curl_config() {
    # Writes a curl '--config' file with the vendor Bearer header (only if a
    # token is available; anonymous read needs none) and prints its path.
    # Keeping the token out of argv is what keeps it off 'ps' and out of
    # 'set -o xtrace' output.
    [ -n "${VENDOR_TOKEN:-}" ] || return 0
    __kvcc_old_umask="$(umask)"
    umask 077
    __kvcc_file="$(mktemp -t koopa-vendor-auth-XXXXXX)"
    umask "$__kvcc_old_umask"
    printf 'header = "Authorization: Bearer %s"\n' "$VENDOR_TOKEN" > "$__kvcc_file"
    printf '%s\n' "$__kvcc_file"
    unset -v __kvcc_file __kvcc_old_umask
}

download_with_fallback() {
    # usage: download_with_fallback <name> <dirname> <url> [url...]
    # Tries each candidate in order: the primary URL, then the vendor
    # mirror (if a vendor.json is configured, see vendor_load()), then a vendor
    # remote-proxy rewrite of every URL given (if 'http.remotes' is
    # configured; see vendor_rewrite_url()), then the remaining URLs as
    # given. Under pull_priority 'vendor_only', no URL outside the vendor
    # mirror and its remote-proxy rewrites is tried at all.
    # Validates each curl-fetched candidate with 'tar -tf' before
    # extracting; an 's3://' candidate is fetched with 'aws s3 cp' instead.
    __dwf_name="${1:?}"
    shift 1
    __dwf_dirname="${1:?}"
    shift 1
    __dwf_primary="${1:?}"
    __dwf_filename="${__dwf_primary##*/}"
    __dwf_filename="${__dwf_filename%%\?*}"
    __dwf_vendor="$(vendor_urls_for "$__dwf_name" "$__dwf_filename")"
    # Command substitution strips the trailing newline vendor_urls_for()
    # printed; re-add it so this joins cleanly with what follows below,
    # instead of running on into the next URL with no separator.
    if [ -n "$__dwf_vendor" ]
    then
        __dwf_vendor="${__dwf_vendor}
"
    fi
    __dwf_rewritten=''
    for __dwf_pub in "$@"
    do
        __dwf_rw="$(vendor_rewrite_url "$__dwf_pub")"
        if [ -n "$__dwf_rw" ]
        then
            __dwf_rewritten="${__dwf_rewritten}${__dwf_rw}
"
        fi
    done
    if [ "$VENDOR_ENABLED" = '1' ] && [ "$VENDOR_PULL_PRIORITY" = 'vendor_only' ]
    then
        __dwf_urls="${__dwf_vendor}${__dwf_rewritten}"
        if [ -z "$__dwf_urls" ]
        then
            printf 'Error: vendor_only is configured but no vendor mirror is available for %s (%s).\n' \
                "$__dwf_name" "$__dwf_filename" >&2
            unset -v __dwf_dirname __dwf_filename __dwf_name __dwf_primary __dwf_pub __dwf_rewritten __dwf_rw __dwf_vendor
            return 1
        fi
    else
        __dwf_urls="${__dwf_primary}
${__dwf_vendor}${__dwf_rewritten}"
        shift 1
        for __dwf_pub in "$@"
        do
            __dwf_urls="${__dwf_urls}${__dwf_pub}
"
        done
    fi
    unset -v __dwf_filename __dwf_pub __dwf_primary __dwf_rewritten __dwf_rw __dwf_vendor
    __dwf_src_dir="${DESTDIR}${PREFIX}/src/${__dwf_name}"
    rm -fr "$__dwf_src_dir"
    mkdir -p "$__dwf_src_dir"
    __dwf_ok=0
    while IFS= read -r __dwf_url
    do
        [ -n "$__dwf_url" ] || continue
        printf 'Trying %s.\n' "$__dwf_url"
        case "$__dwf_url" in
            s3://*)
                if ! command -v aws > /dev/null 2>&1
                then
                    printf 'aws CLI not found, cannot fetch %s.\n' "$__dwf_url"
                elif aws s3 cp --only-show-errors \
                    ${VENDOR_S3_PROFILE:+--profile "$VENDOR_S3_PROFILE"} \
                    "$__dwf_url" "${__dwf_src_dir}/src.archive" \
                    && tar -tf "${__dwf_src_dir}/src.archive" > /dev/null 2>&1
                then
                    __dwf_ok=1
                    break
                fi
                ;;
            *)
                __dwf_curl_cfg=''
                if [ -n "$VENDOR_BASE_URL" ]
                then
                    case "$__dwf_url" in
                        "${VENDOR_BASE_URL%/}"/*) __dwf_curl_cfg="$(vendor_curl_config)" ;;
                    esac
                fi
                if curl \
                    --fail \
                    --location \
                    --max-time 300 \
                    ${_curl_verbose:+"$_curl_verbose"} \
                    ${__dwf_curl_cfg:+--config "$__dwf_curl_cfg"} \
                    "$__dwf_url" \
                    -o "${__dwf_src_dir}/src.archive" \
                    && tar -tf "${__dwf_src_dir}/src.archive" > /dev/null 2>&1
                then
                    [ -n "$__dwf_curl_cfg" ] && rm -f "$__dwf_curl_cfg"
                    __dwf_ok=1
                    unset -v __dwf_curl_cfg
                    break
                fi
                [ -n "$__dwf_curl_cfg" ] && rm -f "$__dwf_curl_cfg"
                unset -v __dwf_curl_cfg
                ;;
        esac
        printf 'Download failed or archive is incomplete, trying next source.\n'
        rm -f "${__dwf_src_dir}/src.archive"
    done << EOF
$__dwf_urls
EOF
    unset -v __dwf_urls
    if [ "$__dwf_ok" -eq 0 ]
    then
        printf 'All download sources failed for %s.\n' "$__dwf_name" >&2
        unset -v __dwf_dirname __dwf_name __dwf_ok __dwf_src_dir __dwf_url
        return 1
    fi
    cd "$__dwf_src_dir" || return 1
    tar -xf 'src.archive'
    cd "$__dwf_dirname" || return 1
    unset -v __dwf_dirname __dwf_name __dwf_ok __dwf_src_dir __dwf_url
    return 0
}

install_perl() {
    __kvar_version='5.44.0'
    printf 'Installing perl.\n'
    __kvar_filename="perl-${__kvar_version}.tar.gz"
    __kvar_major="${__kvar_version%%.*}"
    download_with_fallback \
        'perl' \
        "perl-${__kvar_version}" \
        "https://www.cpan.org/src/${__kvar_major}.0/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/perl/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename __kvar_major
    ./Configure \
        -des \
        -Dprefix="$PREFIX" \
        -Duserelocatableinc \
        || return 1
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}" || return 1
    make install DESTDIR="$DESTDIR" || return 1
    [ -x "${DESTDIR}${PREFIX}/bin/perl" ] || return 1
    PATH="${DESTDIR}${PREFIX}/bin:${PATH}"
    export PATH
    unset -v __kvar_version
    return 0
}

install_openssl() {
    __kvar_version='3.6.3'
    printf 'Installing openssl.\n'
    __kvar_filename="openssl-${__kvar_version}.tar.gz"
    # NOTE: mirror name is 'openssl3', matching the app.json key (and
    # koopa.develop mirror-src's upload path), not the 'openssl' function
    # name -- using the function name here 404s against the koopa mirror.
    download_with_fallback \
        'openssl3' \
        "openssl-${__kvar_version}" \
        "https://github.com/openssl/openssl/releases/download/openssl-${__kvar_version}/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/openssl3/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    ./config \
        --libdir='lib' \
        --openssldir="$PREFIX" \
        --prefix="$PREFIX" \
        "-Wl,-rpath,${PREFIX}/lib" \
        'no-docs' \
        'no-legacy' \
        'no-tests' \
        'no-zlib' \
        'shared' \
        || return 1
    [ -f 'Makefile' ] || {
        printf 'OpenSSL configure failed (no Makefile generated).\n' >&2
        return 1
    }
    make ${_make_verbose:+"$_make_verbose"} --jobs=1 depend || return 1
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}" || return 1
    make install_sw DESTDIR="$DESTDIR" || return 1
    [ -x "${DESTDIR}${PREFIX}/bin/openssl" ] || return 1
    unset -v __kvar_version
    return 0
}

install_python() {
    __kvar_version='3.14.7'
    printf 'Installing python.\n'
    # On macOS, dylib install_names are baked in as absolute paths at build
    # time. Symlink PREFIX/lib -> staged lib so they resolve during build and
    # integrity checks. Not needed on Linux where LD_LIBRARY_PATH suffices.
    __kvar_remove_lib_symlink=0
    if is_macos && [ -n "$DESTDIR" ] && [ ! -d "${PREFIX}/lib" ]
    then
        if [ "${__kvar_use_sudo:-0}" -eq 1 ]
        then
            sudo /bin/mkdir -p "$PREFIX"
            sudo /bin/ln -snf "${DESTDIR}${PREFIX}/lib" "${PREFIX}/lib"
        else
            mkdir -p "$PREFIX"
            ln -snf "${DESTDIR}${PREFIX}/lib" "${PREFIX}/lib"
        fi
        __kvar_remove_lib_symlink=1
    fi
    __kvar_filename="Python-${__kvar_version}.tar.xz"
    # NOTE: mirror name tracks .python-version (e.g. 'python3.12'), matching
    # the app.json key, not the 'python' function name -- using the
    # function name here 404s against the koopa mirror.
    __kvar_mirror_name="python$(cat "${KOOPA_PREFIX}/.python-version")"
    download_with_fallback \
        "$__kvar_mirror_name" \
        "Python-${__kvar_version}" \
        "https://www.python.org/ftp/python/${__kvar_version}/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/${__kvar_mirror_name}/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename __kvar_mirror_name
    export BZIP2_CFLAGS="-I${DESTDIR}${PREFIX}/include"
    export BZIP2_LIBS="-L${DESTDIR}${PREFIX}/lib -lbz2"
    export LIBFFI_CFLAGS="-I${DESTDIR}${PREFIX}/include"
    export LIBFFI_LIBS="-L${DESTDIR}${PREFIX}/lib -lffi"
    export LIBLZMA_CFLAGS="-I${DESTDIR}${PREFIX}/include"
    export LIBLZMA_LIBS="-L${DESTDIR}${PREFIX}/lib -llzma"
    export LDLIBS='-lbz2 -lcrypto -lffi -llzma -lssl -lz'
    ./configure \
        --disable-test-modules \
        --without-ensurepip \
        --prefix="$PREFIX" \
        --with-openssl="${DESTDIR}${PREFIX}" \
        || return 1
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}" || return 1
    make install DESTDIR="$DESTDIR" || return 1
    unset -v BZIP2_CFLAGS BZIP2_LIBS LDLIBS LIBFFI_CFLAGS LIBFFI_LIBS LIBLZMA_CFLAGS LIBLZMA_LIBS
    [ -x "${DESTDIR}${PREFIX}/bin/python3" ] || return 1
    printf 'Checking python module integrity.\n'
    if is_macos
    then
        if ! DYLD_LIBRARY_PATH="${DESTDIR}${PREFIX}/lib" \
            PYTHONHOME="${DESTDIR}${PREFIX}" \
            "${DESTDIR}${PREFIX}/bin/python3" -c 'import _bz2, _ctypes, _hashlib, _lzma, _ssl, zlib'
        then
            printf 'Python module integrity check failed.\n' >&2
            return 1
        fi
    else
        if ! LD_LIBRARY_PATH="${DESTDIR}${PREFIX}/lib" \
            PYTHONHOME="${DESTDIR}${PREFIX}" \
            "${DESTDIR}${PREFIX}/bin/python3" -c 'import _bz2, _ctypes, _hashlib, _lzma, _ssl, zlib'
        then
            printf 'Python module integrity check failed.\n' >&2
            return 1
        fi
    fi
    if [ "$__kvar_remove_lib_symlink" -eq 1 ]
    then
        if [ "${__kvar_use_sudo:-0}" -eq 1 ]
        then
            sudo /bin/rm -f "${PREFIX}/lib"
            sudo /bin/rmdir "$PREFIX" 2>/dev/null || true
        else
            rm -f "${PREFIX}/lib"
            rmdir "$PREFIX" 2>/dev/null || true
        fi
    fi
    unset -v __kvar_remove_lib_symlink
    unset -v __kvar_version
    return 0
}

install_bzip2() {
    __kvar_version='1.0.8'
    printf 'Installing bzip2.\n'
    __kvar_filename="bzip2-${__kvar_version}.tar.gz"
    download_with_fallback \
        'bzip2' \
        "bzip2-${__kvar_version}" \
        "https://sourceware.org/pub/bzip2/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/bzip2/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    make \
        CFLAGS='-fPIC -Wall -Winline -O2 -g -D_FILE_OFFSET_BITS=64' \
        ${_make_verbose:+"$_make_verbose"} \
        --jobs="${CPU_COUNT:?}" \
        PREFIX="${DESTDIR}${PREFIX}" \
        install \
        || return 1
    [ -f "${DESTDIR}${PREFIX}/lib/libbz2.a" ] || return 1
    [ -f "${DESTDIR}${PREFIX}/include/bzlib.h" ] || return 1
    mkdir -p "${DESTDIR}${PREFIX}/lib/pkgconfig"
    cat > "${DESTDIR}${PREFIX}/lib/pkgconfig/bzip2.pc" << BZIP2_PC_EOF
prefix=${PREFIX}
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: bzip2
Description: Lossless, block-sorting data compression
Version: ${__kvar_version}
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
BZIP2_PC_EOF
    [ -f "${DESTDIR}${PREFIX}/lib/pkgconfig/bzip2.pc" ] || return 1
    (
        cd "${DESTDIR}${PREFIX}/bin"
        ln -sf bzdiff bzcmp
        ln -sf bzgrep bzegrep
        ln -sf bzgrep bzfgrep
        ln -sf bzmore bzless
    )
    unset -v __kvar_version
    return 0
}

install_xz() {
    __kvar_version='5.8.3'
    printf 'Installing xz.\n'
    __kvar_filename="xz-${__kvar_version}.tar.gz"
    download_with_fallback \
        'xz' \
        "xz-${__kvar_version}" \
        "https://github.com/tukaani-project/xz/releases/download/v${__kvar_version}/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/xz/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    ./configure \
        CFLAGS='-fPIC' \
        --disable-dependency-tracking \
        --disable-nls \
        --disable-shared \
        --prefix="$PREFIX" \
        || return 1
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}" || return 1
    make install DESTDIR="$DESTDIR" || return 1
    [ -f "${DESTDIR}${PREFIX}/lib/liblzma.a" ] || return 1
    unset -v __kvar_version
    return 0
}

install_libffi() {
    __kvar_version='3.8.0'
    printf 'Installing libffi.\n'
    __kvar_filename="libffi-${__kvar_version}.tar.gz"
    download_with_fallback \
        'libffi' \
        "libffi-${__kvar_version}" \
        "https://github.com/libffi/libffi/releases/download/v${__kvar_version}/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/libffi/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    ./configure \
        CFLAGS='-fPIC' \
        --disable-multi-os-directory \
        --disable-shared \
        --includedir="${PREFIX}/include" \
        --libdir="${PREFIX}/lib" \
        --prefix="$PREFIX" \
        || return 1
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}" || return 1
    make install DESTDIR="$DESTDIR" || return 1
    [ -f "${DESTDIR}${PREFIX}/lib/libffi.a" ] || return 1
    unset -v __kvar_version
    return 0
}

install_zlib() {
    __kvar_version='1.3.2'
    printf 'Installing zlib.\n'
    __kvar_filename="zlib-${__kvar_version}.tar.gz"
    download_with_fallback \
        'zlib' \
        "zlib-${__kvar_version}" \
        "https://koopa.acidgenomics.com/src/zlib/${__kvar_filename}" \
        "https://www.zlib.net/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    ./configure --prefix="$PREFIX" || return 1
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}" || return 1
    make install DESTDIR="$DESTDIR" || return 1
    [ -f "${DESTDIR}${PREFIX}/lib/libz.a" ] || return 1
    unset -v __kvar_version
    return 0
}

install_python_uv() {
    __kvar_uv_version='0.12.4'
    __kvar_python_version='3.14.7'
    printf 'Installing python via uv.\n'
    __kvar_tmpdir="$(mktemp -d -t koopa-uv-XXXXXX)"
    if is_macos && is_arm64
    then
        __kvar_platform='aarch64-apple-darwin'
    elif is_arm64
    then
        __kvar_platform='aarch64-unknown-linux-gnu'
    elif is_amd64
    then
        __kvar_platform='x86_64-unknown-linux-gnu'
    else
        printf 'Unsupported platform for uv.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv_version
        return 1
    fi
    if [ "$VENDOR_ENABLED" = '1' ]
    then
        # A vendor mirror rarely hosts the uv binary itself (app.json gives
        # uv no 'src_url', so 'koopa develop mirror-src' never populates
        # it); take it from PATH instead of fetching it from GitHub.
        __kvar_uv="$(command -v uv || true)"
        if [ -z "$__kvar_uv" ]
        then
            printf 'uv not found on PATH; a vendor-restricted network needs a pre-installed uv.\n' >&2
            rm -fr "$__kvar_tmpdir"
            unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_version
            return 1
        fi
    else
        __kvar_uv_url="https://github.com/astral-sh/uv/releases/download/${__kvar_uv_version}/uv-${__kvar_platform}.tar.gz"
        printf 'Downloading uv %s.\n' "$__kvar_uv_version"
        if ! curl \
            --fail \
            --location \
            --max-time 60 \
            ${_curl_verbose:+"$_curl_verbose"} \
            "$__kvar_uv_url" \
            -o "${__kvar_tmpdir}/uv.tar.gz"
        then
            printf 'Failed to download uv.\n' >&2
            rm -fr "$__kvar_tmpdir"
            unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv_url __kvar_uv_version
            return 1
        fi
        tar -xf "${__kvar_tmpdir}/uv.tar.gz" -C "$__kvar_tmpdir"
        __kvar_uv="${__kvar_tmpdir}/uv-${__kvar_platform}/uv"
        if [ ! -x "$__kvar_uv" ]
        then
            printf 'uv binary not found after extraction.\n' >&2
            rm -fr "$__kvar_tmpdir"
            unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
            return 1
        fi
    fi
    if [ -z "${UV_PYTHON_INSTALL_MIRROR:-}" ] && [ "$VENDOR_ENABLED" = '1' ]
    then
        # uv reads this env var natively to replace the
        # python-build-standalone release host in the URL it constructs;
        # confirmed empirically against uv 0.12.3 even though it carries no
        # '[env:]' annotation in `uv python install --help`.
        __kvar_uv_mirror="$(vendor_rewrite_url 'https://github.com/astral-sh/python-build-standalone/releases/download')"
        if [ -n "$__kvar_uv_mirror" ]
        then
            UV_PYTHON_INSTALL_MIRROR="$__kvar_uv_mirror"
            export UV_PYTHON_INSTALL_MIRROR
        elif [ "$VENDOR_PULL_PRIORITY" = 'vendor_only' ]
        then
            printf 'vendor_only is configured but no remote-proxy mirror is available for python-build-standalone.\n' >&2
            rm -fr "$__kvar_tmpdir"
            unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_mirror __kvar_uv_url __kvar_uv_version
            return 1
        fi
        unset -v __kvar_uv_mirror
    fi
    if [ -z "${UV_HTTP_TIMEOUT:-}" ]
    then
        # Bound the fast-path attempt: a firewall that blackholes the CDN
        # (rather than actively refusing it) must fail quickly and fall
        # through to the source build, not hang.
        UV_HTTP_TIMEOUT=60
        export UV_HTTP_TIMEOUT
    fi
    __kvar_cpython_dir="${__kvar_tmpdir}/cpython"
    printf 'Installing cpython %s via uv.\n' "$__kvar_python_version"
    if ! "$__kvar_uv" python install \
        --install-dir "$__kvar_cpython_dir" \
        --no-bin \
        --no-cache \
        --no-config \
        "$__kvar_python_version"
    then
        printf 'uv python install failed.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    __kvar_cpython_subdir="$(find "$__kvar_cpython_dir" -mindepth 1 -maxdepth 1 -type d | head -1)"
    if [ -z "$__kvar_cpython_subdir" ]
    then
        printf 'No cpython directory found after install.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    __kvar_target="${DESTDIR}${PREFIX}"
    mkdir -p "$__kvar_target"
    cp -R "$__kvar_cpython_subdir"/. "$__kvar_target"/
    if [ ! -x "${__kvar_target}/bin/python3" ]
    then
        printf 'python3 binary not found after copy.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_target __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    printf 'Checking python module integrity.\n'
    if ! "${__kvar_target}/bin/python3" -c 'import _bz2, _ctypes, _hashlib, _lzma, _ssl, zlib'
    then
        printf 'Python module integrity check failed.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_target __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    rm -fr "$__kvar_tmpdir"
    unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_target __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
    return 0
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KOOPA_PREFIX="$SCRIPT_DIR"
BOOTSTRAP_VERSION="$(cat "${KOOPA_PREFIX}/etc/koopa/bootstrap-version.txt")"

PREFIX="${PREFIX:-}"
if [ -z "$PREFIX" ]
then
    PREFIX="${KOOPA_PREFIX}-bootstrap"
fi
if [ -n "${LOADEDMODULES:-}" ]
then
    PATH="${PREFIX}/bin:${PATH}"
else
    PATH="${PREFIX}/bin:/usr/bin:/bin"
fi
CPU_COUNT="$(cpu_count)"
DESTDIR=''
export CPU_COUNT DESTDIR PATH PREFIX

main() {
    vendor_load
    if is_macos && is_amd64
    then
        printf 'Error: Intel Mac (x86_64) is no longer supported.\n' >&2
        printf 'koopa requires macOS on Apple Silicon (arm64).\n' >&2
        return 1
    fi
    __kvar_prefix_parent="$(dirname "$PREFIX")"
    if [ -w "$__kvar_prefix_parent" ]
    then
        __kvar_destdir="${PREFIX}.staging.$$"
        __kvar_use_sudo=0
    else
        __kvar_destdir="$(mktemp -d -t koopa-bootstrap-XXXXXX)"
        __kvar_use_sudo=1
    fi
    unset -v __kvar_prefix_parent
    rm -fr "$__kvar_destdir"
    __kvar_build_ok=0
    # Always try the uv fast path first: a prebuilt CPython download takes
    # seconds versus minutes to compile from source, and this is safe on a
    # genuinely firewalled host too -- install_python_uv fails cleanly (e.g.
    # vendor_only with no derivable mirror, no uv on PATH, or an unreachable
    # CDN) and this falls through to the source build below, same as any
    # other fast-path failure.
    if (
        DESTDIR="$__kvar_destdir"
        export DESTDIR
        install_python_uv
    )
    then
        __kvar_build_ok=1
    else
        printf 'uv fast path failed, falling back to source build.\n' >&2
        rm -fr "$__kvar_destdir"
        mkdir -p "$__kvar_destdir"
    fi
    if [ "$__kvar_build_ok" -eq 0 ]
    then
        printf 'Building from source: openssl3, zlib, bzip2, xz, python.\n'
        if ! (
            DESTDIR="$__kvar_destdir"
            export DESTDIR
            __kvar_staged="${DESTDIR}${PREFIX}"
            mkdir -p "$__kvar_staged"
            export CPPFLAGS="-I${__kvar_staged:?}/include"
            export LDFLAGS="-L${__kvar_staged:?}/lib -Wl,-rpath,${PREFIX:?}/lib"
            if ! is_macos
            then
                export LD_LIBRARY_PATH="${__kvar_staged:?}/lib"
            fi
            export LIBRARY_PATH="${__kvar_staged:?}/lib:/usr/lib"
            export PKG_CONFIG_PATH="${__kvar_staged:?}/lib/pkgconfig"
            if ! perl -e 'use IPC::Cmd;' 2>/dev/null
            then
                printf 'System perl is missing IPC::Cmd; building perl from source.\n'
                install_perl
            fi
            install_openssl
            install_zlib
            install_bzip2
            install_xz
            install_libffi
            install_python
        )
        then
            printf 'Bootstrap build failed.\n' >&2
            rm -fr "$__kvar_destdir"
            unset -v __kvar_build_ok __kvar_destdir __kvar_use_sudo
            return 1
        fi
    fi
    unset -v __kvar_build_ok
    __kvar_staged="${__kvar_destdir}${PREFIX}"
    rm -fr "${__kvar_staged}/src"
    if [ -d "$PREFIX" ]
    then
        if [ "$__kvar_use_sudo" -eq 1 ]
        then
            sudo /bin/rm -fr "${PREFIX}.old" 2>/dev/null || true
            if [ -d "${PREFIX}.old" ]; then
                sudo /bin/mv -f "${PREFIX}.old" "${PREFIX}.old.$$"
            fi
            sudo /bin/mv "$PREFIX" "${PREFIX}.old"
        else
            rm -fr "${PREFIX}.old" 2>/dev/null || true
            if [ -d "${PREFIX}.old" ]; then
                mv -f "${PREFIX}.old" "${PREFIX}.old.$$"
            fi
            mv "$PREFIX" "${PREFIX}.old"
        fi
    elif [ "$__kvar_use_sudo" -eq 1 ]
    then
        sudo /bin/rm -fr "${PREFIX}.old" 2>/dev/null || true
        if [ -d "${PREFIX}.old" ]; then
            sudo /bin/mv -f "${PREFIX}.old" "${PREFIX}.old.$$"
        fi
    else
        rm -fr "${PREFIX}.old" 2>/dev/null || true
        if [ -d "${PREFIX}.old" ]; then
            mv -f "${PREFIX}.old" "${PREFIX}.old.$$"
        fi
    fi
    if [ "$__kvar_use_sudo" -eq 1 ]
    then
        sudo /bin/mkdir -p "$(dirname "$PREFIX")"
        sudo /bin/mv "$__kvar_staged" "$PREFIX"
        sudo /usr/sbin/chown -R "$(id -u):$(id -g)" "$PREFIX"
        sudo /bin/rm -fr "${PREFIX}.old" "${PREFIX}.old."* "$__kvar_destdir" 2>/dev/null || true
    else
        mv "$__kvar_staged" "$PREFIX"
        rm -fr "${PREFIX}.old" "${PREFIX}.old."* "$__kvar_destdir" 2>/dev/null || true
    fi
    printf '%s\n' "${BOOTSTRAP_VERSION:?}" > "${PREFIX}/VERSION"
    printf 'Bootstrap version %s installed successfully.\n' "$BOOTSTRAP_VERSION"
    unset -v __kvar_destdir __kvar_use_sudo
    return 0
}

main "$@"
