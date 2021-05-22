#!/usr/bin/env bash

koopa::alpine_install_glibc() { # {{{1
    # """
    # Install glibc
    # @note Updated 2020-07-20.
    #
    # Custom glibc library is required to install conda.
    #
    # See also:
    # - https://github.com/sgerrand/alpine-pkg-glibc
    # - https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc
    # - https://github.com/Docker-Hub-frolvlad/docker-alpine-miniconda3
    # - https://hub.docker.com/r/frolvlad/alpine-glibc/
    # - https://hub.docker.com/r/frolvlad/alpine-miniconda3/
    # - https://stackoverflow.com/questions/47177538/
    # - https://github.com/sgerrand/alpine-pkg-glibc/issues/75
    # - https://github.com/sgerrand/alpine-pkg-glibc/issues/97
    #
    # Using modified approach from:
    # https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc/blob/
    #     master/Dockerfile
    #
    # Check ldconfig:
    # > ldd /usr/glibc-compat/lib/libdl.so.2
    # > ldd /usr/glibc-compat/lib/ld-linux-x86-64.so.2
    #
    # Don't want to see:
    # Error relocating /usr/glibc-compat/lib/...
    # """
    local apk_bin_file apk_dev_file apk_i18n_file apk_main_file base_url name
    local name_fancy version
    name='glibc'
    version='2.30-r0'
    name_fancy="${name} ${version}"
    koopa::install_start "$name_fancy"
    # Add key required for signed apk releases.
    pub_key='sgerrand.rsa.pub'
    wget "https://alpine-pkgs.sgerrand.com/${pub_key}"
    koopa::cp -S "$pub_key" "/etc/apk/keys/${pub_key}"
    apk_bin_file="glibc-bin-${version}.apk"
    apk_dev_file="glibc-dev-${version}.apk"
    apk_i18n_file="glibc-i18n-${version}.apk"
    apk_main_file="glibc-${version}.apk"
    base_url="https://github.com/sgerrand/alpine-pkg-glibc/\
releases/download/${version}"
    koopa::download "${base_url}/${apk_bin_file}"
    koopa::download "${base_url}/${apk_dev_file}"
    koopa::download "${base_url}/${apk_i18n_file}"
    koopa::download "${base_url}/${apk_main_file}"
    sudo apk add \
        "$apk_bin_file" \
        "$apk_dev_file" \
        "$apk_i18n_file" \
        "$apk_main_file"
    # Setting en_US.UTF-8 by default, as recommended by alpine-pkg-glibc repo.
    /usr/glibc-compat/bin/localedef \
        -f 'UTF-8' \
        -i 'en_US' \
        'en_US.UTF-8' \
        || true
    # docker-alpine-glibc approach for setting C.UTF-8 locale as default.
    # > [[ -n "${LANG:-}" ]] || LANG='C.UTF-8'
    # > /usr/glibc-compat/bin/localedef \
    # >     --charmap 'UTF-8' "$LANG" \
    # >     --force \
    # >     --inputfile 'POSIX' \
    # >     || true
    koopa::rm \
        "$apk_bin_file" \
        "$apk_dev_file" \
        "$apk_i18n_file" \
        "$apk_main_file" \
        "$pub_key"
    koopa::install_success "$name_fancy"
    return 0
}

