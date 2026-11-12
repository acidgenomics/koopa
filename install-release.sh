#!/bin/sh

# Install a stable koopa release without contacting GitHub.
set -eu

base='https://koopa.acidgenomics.com/releases'
version='latest'
if [ "${1:-}" = '--version' ]
then
    version="${2:?Missing release version}"
    shift 2
fi
case "$version" in
    latest) manifest="${base}/latest" ;;
    *)
        case "$version" in
            [0-9]*) version="v${version}" ;;
        esac
        if ! printf '%s\n' "$version" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'
        then
            printf 'Invalid release version: %s\n' "$version" >&2
            exit 1
        fi
        manifest="${base}/${version}/manifest"
        ;;
esac
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
curl --fail --silent --show-error --location "$manifest" -o "${tmp_dir}/manifest"
read -r tag checksum < "${tmp_dir}/manifest"
if ! printf '%s\n' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' \
    || ! printf '%s\n' "$checksum" | grep -Eq '^[0-9a-f]{64}$'
then
    printf 'Invalid release manifest.\n' >&2
    exit 1
fi
if [ "$version" != 'latest' ] && [ "$version" != "$tag" ]
then
    printf 'Release manifest version mismatch.\n' >&2
    exit 1
fi
archive="${tmp_dir}/koopa.tar.gz"
curl --fail --show-error --location --retry 2 \
    "${base}/${tag}/koopa.tar.gz" -o "$archive"
if command -v sha256sum > /dev/null 2>&1
then
    actual="$(sha256sum "$archive")"
elif command -v shasum > /dev/null 2>&1
then
    actual="$(shasum -a 256 "$archive")"
else
    printf 'sha256sum or shasum is required.\n' >&2
    exit 1
fi
actual="${actual%% *}"
if [ "$actual" != "$checksum" ]
then
    printf 'Release archive checksum mismatch.\n' >&2
    exit 1
fi
mkdir "${tmp_dir}/koopa"
tar -xzf "$archive" -C "${tmp_dir}/koopa"
cd "${tmp_dir}/koopa"
groups="$(id -Gn)"
case "$(uname -s): $groups " in
    *'Darwin:'*' admin '* | *'Linux:'*' sudo '* | *'Linux:'*' wheel '*) shared=1 ;;
    *) shared=0 ;;
esac
if [ "$(id -u)" -eq 0 ] || [ "$shared" -eq 1 ]
then
    koopa_prefix='/opt/koopa'
else
    koopa_prefix="${XDG_DATA_HOME:-${HOME:?}/.local/share}/koopa"
fi
if [ -e "$koopa_prefix" ]
then
    printf 'Install prefix already exists: %s\n' "$koopa_prefix" >&2
    exit 1
fi
KOOPA_BOOTSTRAP_PREFIX="${koopa_prefix}-bootstrap"
export KOOPA_BOOTSTRAP_PREFIX
PREFIX="$KOOPA_BOOTSTRAP_PREFIX" sh ./bootstrap.sh
./bin/koopa install koopa "$@"
