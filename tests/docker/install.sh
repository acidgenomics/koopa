#!/usr/bin/env bash
# shellcheck disable=SC2034
set -Eeu -o pipefail

# """
# Install koopa inside Docker.
# Updated 2020-03-07.
# """

[[ -z "${image:-}" ]] && image="acidgenomics/debian"
[[ -z "${tag:-}" ]] && tag="minimal"

image="${image}:${tag}"

case "$image" in
    debian:*)
        cmd="\
            apt-get update && \
            DEBIAN_FRONTEND=noninteractive \
            apt-get \
                --no-install-recommends \
                --quiet \
                --yes \
                install \
                    bc \
                    ca-certificates \
                    curl \
                    git \
                    gnupg \
                    lsb-release \
                    sudo"
        ;;
    fedora:*)
        cmd="dnf -y install bc curl git sudo"
        ;;
esac

cmd="\
    rm -fr /usr/local/koopa && \
    curl -sSL https://koopa.acidgenomics.com/install \
        | bash -s -- --non-interactive --test"

docker pull "$image"
docker run -it "$image" bash -c "$cmd"
