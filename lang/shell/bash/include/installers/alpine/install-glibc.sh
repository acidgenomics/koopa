#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

alpine_install_glibc() { # {{{1
    # """
    # Install glibc.
    # @note Updated 2021-11-02.
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
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apk]="$(koopa_alpine_locate_apk)"
        [localedef]="$(koopa_alpine_locate_localedef)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [version]="${INSTALL_VERSION:?}"
        [base_url]="https://github.com/sgerrand/alpine-pkg-glibc/\
releases/download/${dict[version]}"
        [apk_key_prefix]='/etc/apk/keys'
        [apk_bin_url]="${dict[base_url]}/glibc-bin-${dict[version]}.apk"
        [apk_dev_url]="${dict[base_url]}/glibc-dev-${dict[version]}.apk"
        [apk_i18n_url]="${dict[base_url]}/glibc-i18n-${dict[version]}.apk"
        [apk_main_url]="${dict[base_url]}/glibc-${dict[version]}.apk"
        [pub_key_url]='https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub'
    )
    dict[apk_bin_file]="$(koopa_basename "${dict[apk_bin_url]}")"
    dict[apk_dev_file]="$(koopa_basename "${dict[apk_dev_url]}")"
    dict[apk_i18n_file]="$(koopa_basename "${dict[apk_i18n_url]}")"
    dict[apk_main_file]="$(koopa_basename "${dict[apk_main_url]}")"
    dict[pub_key_file]="$(koopa_basename "${dict[pub_key_url]}")"
    koopa_download "${dict[apk_bin_url]}" "${dict[apk_bin_file]}"
    koopa_download "${dict[apk_dev_url]}" "${dict[apk_dev_file]}"
    koopa_download "${dict[apk_i18n_url]}" "${dict[apk_i18n_file]}"
    koopa_download "${dict[apk_main_url]}" "${dict[apk_main_file]}"
    koopa_download "${dict[pub_key_url]}" "${dict[pub_key_file]}"
    koopa_cp --sudo \
        "${dict[pub_key_file]}" \
        "${dict[apk_key_prefix]}/${dict[pub_key_file]}"
    "${app[sudo]}" "${app[apk]}" add \
        "${dict[apk_bin_file]}" \
        "${dict[apk_dev_file]}" \
        "${dict[apk_i18n_file]}" \
        "${dict[apk_main_file]}"
    # Setting en_US.UTF-8 by default, as recommended by alpine-pkg-glibc repo.
    "${app[localedef]}" -f 'UTF-8' -i 'en_US' 'en_US.UTF-8' || true
    # docker-alpine-glibc approach for setting 'C.UTF-8' locale as default.
    # > [[ -n "${LANG:-}" ]] || LANG='C.UTF-8'
    # > "${app[localedef]}" \
    # >     --charmap 'UTF-8' "$LANG" \
    # >     --force \
    # >     --inputfile 'POSIX' \
    # >     || true
    return 0
}
