#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# koopa piped install script.
# Updated 2020-02-15.
#
# This downloads a copy of the latest stable release into a temporary directory.
# """

release="latest"

if [[ "$#" -gt 0 ]]
then
    pos=()
    while (("$#"))
    do
        case "$1" in
        --release=*)
            release="${1#*=}"
            shift 1
            ;;
        --release)
            release="$2"
            shift 2
            ;;
        *)
            pos+=("$1")
            shift 1
            ;;
        esac
    done
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
    fi
fi

# Note that use of 'api.github.com' here returns JSON instead of HTML.
url="https://api.github.com/repos/acidgenomics/koopa/releases/${release}"
json="$(curl -s "$url")"

tarball_url="$( \
    echo "$json" \
        | grep '"tarball_url":' \
        | cut -d '\"' -f 4 \
)"

tag_name="$( \
    echo "$json" \
        | grep '"tag_name":' \
        | cut -d '\"' -f 4 \
)"

echo "Installing koopa ${tag_name}."

tmp_dir="$(mktemp -d)"

(
    cd "$tmp_dir" || exit 1
    file="koopa.tar.gz"
    curl --location -o "$file" "$tarball_url"
    tar -xzf "$file"
    cd "acidgenomics-koopa-"* || exit 1
    ./install "$@"
)

rm -fr "$tmp_dir"
