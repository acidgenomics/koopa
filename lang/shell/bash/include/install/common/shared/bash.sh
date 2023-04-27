#!/usr/bin/env bash

# FIXME Is this picking up gettext installed in /usr/local by Homebrew?

main() {
    # """
    # Install Bash.
    # @note Updated 2023-04-10.
    #
    # @section Applying patches:
    #
    # Alternatively, can pipe curl call directly to 'patch -p0'.
    # https://stackoverflow.com/questions/14282617
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bash.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'patch' 'pkg-config'
    app['curl']="$(koopa_locate_curl --allow-system)"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['gnu_mirror']="$(koopa_gnu_mirror_url)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['patch_base_url']="https://ftp.gnu.org/gnu/bash/\
bash-${dict['maj_min_ver']}-patches"
    dict['n_patches']="$( \
        koopa_major_minor_patch_version "${dict['version']}" \
        | "${app['cut']}" -d '.' -f '3' \
    )"
    conf_args=("--prefix=${dict['prefix']}")
    if koopa_is_alpine
    then
        conf_args+=('--without-bash-malloc')
    elif koopa_is_macos
    then
        CFLAGS="-DSSH_SOURCE_BASHRC ${CFLAGS:-}"
        export CFLAGS
    fi
    dict['url']="${dict['gnu_mirror']}/bash/bash-${dict['maj_min_ver']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    if [[ "${dict['n_patches']}" -gt 0 ]]
    then
        koopa_alert "$(koopa_ngettext \
            --prefix='Applying ' \
            --num="${dict['n_patches']}" \
            --msg1='patch' \
            --msg2='patches' \
            --suffix=" from '${dict['patch_base_url']}'." \
        )"
        dict['mmv_tr']="$( \
            koopa_gsub \
                --fixed \
                --pattern='.' \
                --replacement='' \
                "${dict['maj_min_ver']}" \
        )"
        dict['patch_range']="$(printf '%03d-%03d' '1' "${dict['n_patches']}")"
        dict['patch_request_urls']="${dict['patch_base_url']}/\
bash${dict['mmv_tr']}-[${dict['patch_range']}]"
        koopa_mkdir 'patches'
        (
            koopa_cd 'patches'
            "${app['curl']}" "${dict['patch_request_urls']}" -O
            koopa_cd ..
            for file in "patches/"*
            do
                "${app['patch']}" \
                    --ignore-whitespace \
                    --input="$file" \
                    --strip=0 \
                    --verbose
            done
        )
    fi
    koopa_make_build "${conf_args[@]}"
    return 0
}
